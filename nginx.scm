
(use-modules (ice-9 regex))

(define config "
    worker_rlimit_nofile 8192;

    events  { worker_connections  4096; }

    http {
      include mime.types;

      server { 
        listen       8080;
        server_name  localhost;

        default_type  application/octet-stream;
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;

        access_log   nginx-access.log;
        error_log    nginx-error.log;

        location / {
          root    SERVE_PATH;
        }
      }
    }
")

(define mime-types
  "types {
  text/html                   html;
  text/css                    css;
  application/javascript      js;
  application/wasm            wasm;
  }"
  )

(define serve-path 
  (string-append (getcwd)))

(define nginx-path 
  (string-append (getcwd) "/.nginx"))

(define log-path 
  (string-append nginx-path "/logs"))

(define config-path 
  (string-append nginx-path "/nginx.config"))

(define mime-path
  (string-append nginx-path "/mime.types"))

(when (not (file-exists? nginx-path))
  (mkdir nginx-path))

(when (not (file-exists? log-path))
  (mkdir log-path))

(define mime-port (open-output-file mime-path))
(display mime-types mime-port)

(define config-port (open-output-file config-path))
(define config 
  (regexp-substitute 
    #f 
    (string-match "SERVE_PATH" config) 
    'pre serve-path 'post))

(display config config-port)

(close-port mime-port)
(close-port config-port)

(system* "nginx" "-c" config-path  "-g" "daemon off;" "-p" nginx-path)


