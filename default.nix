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
      url = "http://example.com";
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
};
attrsToDirs' "wedding-site" (pages // { "rsvp.html" = rsvp; })
