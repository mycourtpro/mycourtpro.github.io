
Imports System.Web
Imports System.Text
Imports System.Text.RegularExpressions
Imports System.Security.Cryptography

Imports Bc = BCrypt.Net.BCrypt


Public Class MyCourtApiClient

    Implements System.IDisposable

    Private _salt As String

    Private _root As Response
    Public Location As Response

    Public Property EndPoint As String
    Public Property UserEmail As String
    Public Property DeviceName As String
    Public Property KeyId As Integer
    Public Property Secret As String
    Public Property ConfirmationLink As Dict

    Public Sub New(
        endPoint As String,
        userEmail As String,
        deviceName As String,
        Optional keyId As Integer = 0,
        Optional secret As String = Nothing
    )

        Me.EndPoint = endPoint
        Me.UserEmail = userEmail
        Me.DeviceName = deviceName
        Me.KeyId = keyId
        Me.Secret = secret
    End Sub

    Public Overloads Sub Dispose() Implements IDisposable.Dispose

        Me.KeyId = 0
        Me.Secret = Nothing
    End Sub

    Public Function Root() As Response

        If Me._root Is Nothing Then

            Dim r = DoRequest("GET", New Dict("uri", Me.EndPoint), Nothing)

            If r.Status <> 200 Then Return r

            Me._root = r
        End If

        Return Me._root
    End Function

    Public Sub Authenticate()

        Me._salt = Bc.GenerateSalt(14)

        Dim d = New Jo.Dict
        d("userEmail") = Me.UserEmail
        d("deviceName") = Me.DeviceName
        d("salt") = Me._salt

        Dim r = DoRequest("POST", Root.Link("#auth"), d)

        If r.Exception IsNot Nothing Then
            Console.WriteLine(r.Exception.Status)
            Console.WriteLine(r.Exception.ToString)
            Console.WriteLine(r.Exception.Response)
        End If

        Me.KeyId = r.Dict.LookupInt32("keyId")
        Me.ConfirmationLink = r.Link("#auth_confirmation")
    End Sub

    Public Sub ConfirmAuthentication(code As String)

        Me.Secret = Bc.HashPassword(code.Replace(" ", ""), Me._salt)

        Dim d = New Jo.Dict

        DoRequest("POST", Me._ConfirmationLink, d)
    End Sub

    Protected Function DoRequest(
        method As String,
        link As Dict,
        jsonBody As MyCourt.Jo.Dict
    ) As Response

        method = method.ToUpper

        Dim uri = link.Lookup("uri")

        If uri Is Nothing Then
            Throw New ArgumentException("rel '" & link("rel") & "' not found")
        End If

        If uri.EndsWith("/api") Then uri = uri & "/"

        Dim req As System.Net.WebRequest = System.Net.WebRequest.Create(uri)
        req.Method = method

        Dim body = Nothing
        If jsonBody IsNot Nothing Then body = jsonBody.ToJson

        Sign(req, uri, body)

        Dim res As Response

        Try

            If method = "POST" OrElse method = "PUT" Then
                Dim content As Byte() = Encoding.UTF8.GetBytes(body)
                req.ContentType = "application/json; charset=utf-8"
                req.ContentLength = content.Length
                req.GetRequestStream().Write(content, 0, content.Length)
            End If

            res = New Response(Me, uri, req.GetResponse)

        Catch we As System.Net.WebException

            res = New Response(Me, uri, we)
        End Try

        Me.Location = res

        Return res
    End Function

    Protected Sub Sign(
        ByRef req As System.Net.HttpWebRequest,
        uri As String,
        body As String
    )

        If body Is Nothing Then body = ""

        Dim path = uri.Substring(uri.IndexOf("/api/"))

        req.Headers.Add("x-mycourt-date", DateTime.Now.ToHttpDate)

        If Me.Secret Is Nothing Then Return

        Dim l = New List(Of String)
        l.Add(req.Method)
        l.Add(path)
        For Each k As String In req.Headers.Keys
            l.Add(k.ToLower & ":" & req.Headers(k))
        Next
        l.Add(vbLf)
        l.Add(body)
        Dim data = Encoding.UTF8.GetBytes(Util.Join(l, vbLf))

        Dim hmac = New HMACSHA256(Encoding.UTF8.GetBytes(Me.Secret))
        Dim sha256 = New SHA256Managed

        Dim sig = Convert.ToBase64String(hmac.ComputeHash(sha256.ComputeHash(data)))

        Dim signedHeaders = "x-mycourt-date"

        req.Headers.Add(
            "x-mycourt-authorization",
            String.Format(
                "MyCourt KeyId={0},Algorithm=HMACSHA256,SignedHeaders={1},Signature={2}",
                Me.KeyId, signedHeaders, sig))
    End Sub

    Class Response

        Public Property Client As MyCourtApiClient
        Public Property RequestUri As String
        Public Property Response As System.Net.HttpWebResponse
        Public Property Status As Integer
        Public Property Text As String
        Public Property Dict As Jo.WebDict
        Public Property Exception As System.Net.WebException

        Public Sub New(
            ByRef c As MyCourtApiClient,
            requestUri As String,
            ByRef res As System.Net.HttpWebResponse
        )
            Me.Client = c
            Me.RequestUri = requestUri
            Me.Response = res
            Me.Status = Me.Response.StatusCode

            DecodeResponseStream()
        End Sub

        Public Sub New(
            ByRef c As MyCourtApiClient,
            requestUri As String,
            ByRef e As System.Net.WebException
        )

            Me.Client = c
            Me.RequestUri = requestUri
            Me.Exception = e
            Me.Response = e.Response
            Me.Status = Me.Response.StatusCode

            DecodeResponseStream()
        End Sub

        Protected Sub DecodeResponseStream()

            Me.Text = Util.ToUtf8String(Me.Response.GetResponseStream)

            Try
                Dim d As Dict = Jo.Decode(Me.Text)
                Me.Dict = New WebDict(d)
            Catch ex As Exception
                'Console.WriteLine(ex.Message)
            End Try
        End Sub

        Public Function Links() As Dict

            Return Me.Dict.Links
        End Function

        Protected QUERY_STRING_TEMPLATE As Regex =
            New Regex("(.+)\{\?([^\}]+)\}$")

        Public Function Link(
            rel As String, Optional params As Dict = Nothing
        ) As Dict

            Dim l As Dict = Nothing
            Dim ls = Links()

            l = ls.Lookup(rel)
            If rel.StartsWith("#") Then
                Dim k = ls.Keys.FirstOrDefault(Function(r) r.EndsWith(rel))
                If k IsNot Nothing Then l = ls.Lookup(k)
            End If

            If l Is Nothing Then Return New Dict("rel", rel)

            l = l.Copy
            l("rel") = rel
            l("uri") = l("href")

            If l.Lookup("templated") Is Nothing OrElse l("templated") <> True Then Return l

            If params Is Nothing Then params = New Dict

            Dim m = QUERY_STRING_TEMPLATE.Match(l("uri"))
            If m.Success Then
                Dim u = m.Groups(1).ToString
                For Each k In m.Groups(2).ToString.Split(",")
                    Dim v = params.Lookup(k)
                    If v Is Nothing Then Continue For
                    u = u & IIf(u.IndexOf("?") > 1, "&", "?")
                    u = u & HttpUtility.UrlEncode(k) & "=" & HttpUtility.UrlEncode(v)
                Next
                l("uri") = u
            End If

            Dim s As String = l("uri")
            For Each e In params
                s = s.Replace("{" & e.Key & "}", e.Value.ToString)
            Next
            l("uri") = s

            If s.IndexOf("{") > 0 Then
                Throw New ArgumentException("href not fully expanded: " & s)
            End If

            Return l
        End Function

        Public Function Uri(
            rel As String, Optional params As Dict = Nothing
        ) As String

            Dim l = Link(rel, params)
            If l Is Nothing Then Return Nothing

            Return l.Lookup("uri")
        End Function

        Public Function DoGet(
            rel As String, Optional params As Dict = Nothing
        ) As Response

            Return Me.Client.DoRequest("GET", Link(rel, params), Nothing)
        End Function

        Public Function DoPost(
            rel As String, doc As Dict
        ) As Response

            Return DoPost(rel, Nothing, doc)
        End Function

        Public Function DoPost(
            rel As String, params As Dict, doc As Dict
        ) As Response

            ' no fields enforcement for now

            Return Me.Client.DoRequest("POST", Link(rel, params), doc)
        End Function

        Public Function DoDelete(
            rel As String, params As Dict
        ) As Response

            Return Me.Client.DoRequest("DELETE", Link(rel, params), Nothing)
        End Function
    End Class
End Class

