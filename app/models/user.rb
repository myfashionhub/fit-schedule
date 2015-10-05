class User < ActiveRecord::Base

  def self.find_or_create(auth_hash)
    user = User.find_by(google_uid: auth_hash['uid'])
    
    if !user
      user = User.create(
        name: auth_hash['info']['name'],
        email: auth_hash['info']['email'],
        image: auth_hash['info']['image'],
        google_token: auth_hash['credentials']['token']
      )
    end

    user
  end

end


=begin
  
=> {"provider"=>"google_oauth2",
=> {"provider"=>"google_oauth2",
 "uid"=>"117452586588272762290",
 "info"=>
  {"name"=>"Nessa Nguyen",
   "email"=>"v.nessa.nguyen@gmail.com",
   "first_name"=>"Nessa",
   "last_name"=>"Nguyen",
   "image"=>
    "https://lh3.googleusercontent.com/-AHoZuZ-_BWk/AAAAAAAAAAI/AAAAAAAAD4M/6cfIYlr10p4/photo.jpg",
   "urls"=>{"Google"=>"https://plus.google.com/+NessaNguyen"}},
 "credentials"=>
  {"token"=>
    "ya29.AwJvkxxcExvAAkicCQuQbYG2Er32vv5rELINxACEPFrDhdHdUvzd9ByFkTo74nDog5pp",
   "expires_at"=>1444019227,
   "expires"=>true},
 "extra"=>
  {"id_token"=>
    "eyJhbGciOiJSUzI1NiIsImtpZCI6ImExODdiNzEzZjFmNDUyYTQyODkxZmM5NmQ2NzI3NDJlNTYzODgyZmIifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXRfaGFzaCI6Il96RDBQTFZ4QTlqTkd5ZkVCdy1tNlEiLCJhdWQiOiI5MzcxNjE2NDE3NjYtcHJwbTc4ODM0MmdwMmV0NzlvYTcwaWxhbnRpbDgyZTMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTc0NTI1ODY1ODgyNzI3NjIyOTAiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiOTM3MTYxNjQxNzY2LXBycG03ODgzNDJncDJldDc5b2E3MGlsYW50aWw4MmUzLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJ2Lm5lc3NhLm5ndXllbkBnbWFpbC5jb20iLCJpYXQiOjE0NDQwMTU1MTMsImV4cCI6MTQ0NDAxOTExM30.rh66E1px-AYe495BCenFn2VzC9ujKqi-xCKz1y5AHXSP8p8M--XnlF4OA6tOmfHAByLA_EB5yEwJ7bofD4QIsKXKksdc_HoDVlAsLMTcNw_BNNeP98h-7WobhkUnndEdOO4C_LrCno-jC6GwcIqxs4ufdPVEmSF0S-Xq-peHVCa51hXXEr3IAt7ROO5L1b7X9hAcknB0l5dHy-6GNFF4lVbbb4Z5Q0CeKVBY9EHfKBC-MdB1oCClTEao3b9FOjuyih4XRSfOKrCKlM_jByJnKNVtBf2-NmM9_O2SveLHqr_HHCrROVXxy-Tzo_FuEM5djHDsB2OKxW51LtwaPR9yJQ",
   "id_info"=>
    {"iss"=>"accounts.google.com",
     "at_hash"=>"_zD0PLVxA9jNGyfEBw-m6Q",
     "aud"=>
      "937161641766-prpm788342gp2et79oa70ilantil82e3.apps.googleusercontent.com",
     "sub"=>"117452586588272762290",
     "email_verified"=>true,
     "azp"=>
      "937161641766-prpm788342gp2et79oa70ilantil82e3.apps.googleusercontent.com",
     "email"=>"v.nessa.nguyen@gmail.com",
     "iat"=>1444015513,
     "exp"=>1444019113},
   "raw_info"=>
    {"kind"=>"plus#personOpenIdConnect",
     "gender"=>"female",
     "sub"=>"117452586588272762290",
     "name"=>"Nessa Nguyen",
     "given_name"=>"Nessa",
     "family_name"=>"Nguyen",
     "profile"=>"https://plus.google.com/+NessaNguyen",
     "picture"=>
      "https://lh3.googleusercontent.com/-AHoZuZ-_BWk/AAAAAAAAAAI/AAAAAAAAD4M/6cfIYlr10p4/photo.jpg?sz=50",
     "email"=>"v.nessa.nguyen@gmail.com",
     "email_verified"=>"true"}}}
  
=end
