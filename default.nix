with builtins;
with import <nixpkgs> {};
with lib;
with rec {
  bodies = mapAttrs'
    (name: value: { inherit value; name = removeSuffix "-body.html" name; })
    (genAttrs
      (filter (hasSuffix "-body.html") (attrNames (readDir ./.)))
      (f: ./. + "/${f}"));

  compiled = mapAttrs
    (name: bodyPath:  ''
      <html>
        ${readFile ./head.html}
        <body>
          ${readFile ./header.html}
          ${readFile bodyPath}
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
attrsToDirs' "wedding-site" (pages /*// { resources = ./resources; }*/)
