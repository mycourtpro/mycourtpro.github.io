
require 'pp'
require_relative 'mycourt_client'

c = MyCourtClient.new('toto@example.com', 'smahon')
c.authenticate

#<TestMethod()> Public Sub IntApiAuth_happy_path()
#
#    Using client = New MyCourtApiClient(appUri & "/api/", TestHelper.User.Email, "my iphone")
#
#        client.Authenticate()
#
#        Dim apiKey = MyCourtContext.Current.ApiKeys.FirstOrDefault
#
#        Assert.AreEqual(apiKey.Id, client.KeyId)
#        Assert.AreEqual(appUri & "/api/auth/" & apiKey.Id, client.ConfirmationLink("uri"))
#
#        Assert.AreEqual("my iphone", apiKey.DeviceName)
#        Assert.AreEqual(TestHelper.User.Id, apiKey.UserId)
#        Assert.AreEqual("new", apiKey.State)
#
#        'Wait(5000) ' give it some time to send the email...
#
#        Dim code As String = Nothing
#        Using f = New System.IO.StreamReader(System.IO.Path.GetFullPath("./last_code.txt"))
#            code = f.ReadToEnd.Trim
#        End Using
#
#        Dim r = New Regex("^[1-9A-Z]{4} [1-9A-Z]{4} [1-9A-Z]{4} [1-9A-Z]{4}$")
#
#        Assert.IsTrue(r.Match(code).Success, "code >" & code & "< is no matchy...")
#
#        client.ConfirmAuthentication(code)
#
#        MyCourtContext.DoDispose(True) ' to make sure we see the updated database
#
#        apiKey = MyCourt.ApiKey.Find(apiKey.Id)
#
#        Assert.AreEqual("active", apiKey.State)
#    End Using
#End Sub

