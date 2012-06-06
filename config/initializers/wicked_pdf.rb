WickedPdf.config = {

    #:wkhtmltopdf => '/home/user/wkhtmltopdf-i386',
    #:wkhtmltopdf => '/usr/bin/wkhtmltopdf',
    :wkhtmltopdf => '/home/mohan/.rvm/gems/ruby-1.8.7-p358/bin/wkhtmltopdf',
    #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
    :layout => "pdf.html",
    :margin => {    :top=> 40,
                    :bottom => 20,
                    :left=> 30,
                    :right => 30},
    :header => {:html => { :template=> 'layouts/pdf_header.html'}},
    :footer => {:html => { :template=> 'layouts/pdf_footer.html'}}
    #:exe_path => '/usr/bin/wkhtmltopdf'
}
