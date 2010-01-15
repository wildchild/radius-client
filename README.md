Ruby RADIUS client
==================

This is a basic RADIUS client with support for PAP authentication.
This is experimental software. You may hurt yourself while using it.

Synopsys
--------

    dict = RADIUS::Dictionary.new
    dict << RADIUS::Attribute.new("User-Name", 1, :string)
    dict << RADIUS::Attribute.new("User-Password", 2, :string)
    client = RADIUS::Client.new(dict, "0.0.0.0:1812")
    pap = RADIUS::PAP.new("username", "password", "secret")
    request = RADIUS::AccessRequest.new(dict, pap)
    request.identifier = 1
    response = client.send(request)

Contribution
------------

Feel free to report issues and suggestions, patches are also welcome.

Credits
-------

* Alexander Uvarov [http://github.com/wildchild](http://github.com/wildchild)
