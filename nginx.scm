(use-modules (ice-9 regex))

(define raw-config "
    daemon off;
    worker_rlimit_nofile 8192;

    events  { worker_connections  4096; }

    http {
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
          root    SERVE_PATH
        }
      }
    }
")

(define serve-path 
  (string-append (getcwd)))

(define nginx-path 
  (string-append (getcwd) "/.nginx"))

(define log-path 
  (string-append nginx-path "/logs"))

(define config-path 
  (string-append nginx-path "/nginx.config"))

(when (not (file-exists? nginx-path))
  (mkdir nginx-path))

(when (not (file-exists? log-path))
  (mkdir log-path))

(define port (open-output-file config-path))
(define config 
  (regexp-substitute 
    #f 
    (string-match "SERVE_PATH" raw-config) 
    'pre serve-path 'post))

(display config port)

(system* "nginx" "-c" config-path "-p" nginx-path)
