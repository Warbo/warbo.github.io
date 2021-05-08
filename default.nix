with builtins;
with import <nixpkgs> {};
with lib;
with rec {
  bodies = mapAttrs'
    (name: value: { inherit value; name = removeSuffix "-body.html" name; })
    (genAttrs
      (filter (hasSuffix "-body.html") (attrNames (readDir ./.)))
      (f: ./. + "/${f}"));

  rsvp =
    with {
      url = "https://forms.gle/28jaAHbJXWtiEmwQ9";
    };
    writeText "rsvp.html" ''
      <html>
        <head>
          <meta http-equiv="refresh" content="0; url=${url}">
        </head>
        <body onload="window.location = '${url}'">
          <a href="${url}">CLICK HERE FOR RSVP FORM</a>
        </body>
      </html>
    '';

  compiled = mapAttrs
    (name: bodyPath:  ''
      <html id="${name}-page">
        ${readFile ./head.html}
        <body>
          ${readFile ./header.html}
          <article>
            ${readFile bodyPath}
          </article>
        </body>
      </html>
    '')
    bodies;

  pages = mapAttrs'
    (page: content: rec {
      name  = page + ".html";
      value = writeText name content;
    })
    compiled;

  invite = runCommand "invite.html"
    {
      buildInputs = [ coreutils python ];
      raw         = ./invite-imageless.html;
      image1      = ./invite_files/s.jpg;
      image2      = ./invite_files/s.svg;
      splice      = writeText "splice.py" ''
        from sys import stdin, stdout

        with open('image1.b64', 'r') as f:
          image1 = f.read()
        with open('image2.b64', 'r') as f:
          image2 = f.read()

        stdout.write(
          stdin.read().replace(
            'IMAGEDATA1',
            image1
          ).replace(
            'IMAGEDATA2',
            image2
          )
        )
      '';
    }
    ''
      base64 -w0 < "$image1" > image1.b64
      base64 -w0 < "$image2" > image2.b64
      python "$splice" < "$raw" > "$out"
    '';

};
attrsToDirs' "wedding-site" (pages // {
  "invite.html" = invite;
  "rsvp.html"   = rsvp;
})
