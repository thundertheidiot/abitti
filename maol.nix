{
  stdenvNoCC,
  maol-content,
  nginx,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "maol";

  srcs = null;
  unpackPhase = "true";

  installPhase = let
    config = ''
      user nobody nobody;
      daemon off;
      pid /dev/null;
      error_log /dev/stdout info;

      events {}
      http {
        include ${nginx}/conf/mime.types;
        access_log /dev/stdout;

        server {
          listen 8000;
          server_name 0.0.0.0;

          root ${maol-content};
          index index.html;

          location / {
            try_files \$uri \$uri/ =404;
          }
        }
      }
    '';

    script = ''
      #!/bin/sh
      ${nginx}/bin/nginx -c $out/nginx.conf
    '';
  in ''
    mkdir -p $out/bin

    echo "${config}" > $out/nginx.conf
    echo "${script}" > $out/bin/maol
    chmod +x $out/bin/maol
  '';
}
