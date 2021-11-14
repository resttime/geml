(defpackage #:geml.server
  (:use #:cl)
  (:local-nicknames (:us :usocket)))
(in-package #:geml.server)

(defun write-file (filepath conn)
  (with-open-file (in filepath :element-type '(unsigned-byte 8))
    (loop
      with buffer = (make-array 1024 :element-type '(unsigned-byte 8))
      for pos = (read-sequence buffer in)
      until (zerop pos)
      do (write-sequence buffer conn :end pos))))

(defun handle-request (conn)
  (let ((req (read-line conn)))
    (format t "Request: ~a~%" req)
    (write-line "20 text/gemini" conn)
    ;; (write-file "../hi.gmi" conn)
    (format conn "# Welcome~%content")
    (force-output conn)))

(defun start-server (cert key)
  (let ((server (us:socket-listen "localhost" 1965)))
    (unwind-protect
         (loop (let* ((socket (us:socket-accept server))
                      (conn (cl+ssl:make-ssl-server-stream
                             (us:socket-stream socket)
                             :external-format '(:utf-8 :eol-style :crlf)
                             :certificate cert
                             :key key)))
                 (unwind-protect (handle-request conn)
                   (close conn))))
      (format t "Closing Server~%")
      (us:socket-close server))))

(defun test ()
  (let* ((socket (us:socket-connect "localhost" 1965))
         (conn (cl+ssl:make-ssl-client-stream
                (us:socket-stream socket)
                :external-format '(:utf-8 :eol-style :crlf)
                :verify nil)))
    (unwind-protect
         (progn
           (write-line "gemini://localhost/test" conn)
           (force-output conn)
           (format t "Response Header:~%~a~%~%" (read-line conn))
           (format t "Response Body:~%")
           (loop with buffer = (make-array 1024 :element-type 'character)
                 for pos = (read-sequence buffer conn)
                 until (zerop pos)
                 do (write-sequence buffer *standard-output* :end pos)))
      (close conn))))
