unit UHttpRequest;

interface

// @define uses
uses
  Windows, SysUtils, Variants, Classes, Dialogs,
  IdHttp, IdMultipartFormData, IdSSLOpenSSL;

type
  THttpRequest = class(TObject)
    // @private
    private
      URL: string;

    // @private
    private
      IdHttp: TIdHTTP;
      Retorno: string;
      IdMultiPartFormDataStream: TIdMultiPartFormDataStream;
      LHandler: TIdSSLIOHandlerSocketOpenSSL;

    // @private
    private
      procedure initComponents;

    // @public
    public
      function Post(
        IdMultiPartFormDataStream: TIdMultiPartFormDataStream
      ) : string;

    // @public
    public
      constructor Create( fURL: string );
      destructor Destroy;
  end;

// @define implementation
implementation

{ THttpRequest }

// @THttpRequest::Create
constructor THttpRequest.Create( fURL: string );
begin
  // @definir URL
  URL := fURL;

  // @initComponents
  initComponents();
end;

// @THttpRequest::initComponents
procedure THttpRequest.initComponents;
begin
  IdHttp := TIdHTTP.Create(nil);
  IdMultiPartFormDataStream := TIdMultiPartFormDataStream.Create;
  LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  
  // @define LHandler
  with LHandler do begin
    SSLOptions.Method := sslvTLSv1;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 0;
    Host := '';
  end;
end;

// @THttpRequest::Post
function THttpRequest.Post( IdMultiPartFormDataStream: TIdMultiPartFormDataStream ): string;
begin
  try
    try
      IdHttp.IOHandler := LHandler;
      IdHttp.Request.Accept := 'text/html, */*';
      IdHttp.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/25.0';
      IdHttp.Request.ContentType := 'application/x-www-form-urlencoded';
      IdHttp.HandleRedirects := True;

      // @Define Returno
      Result := UTF8Decode( IdHttp.Post(
        URL, IdMultiPartFormDataStream
      ));

    // @define Error Exception
    except on E: Exception do
      ShowMessage( 'Error: ' + E.Message );
    end;

  finally
    LHandler.Free;
    IdHttp.Free;
  end;
end;

// @THttpRequest::Destroy
destructor THttpRequest.Destroy;
begin
  IdHttp.Destroy();
  IdMultiPartFormDataStream.Destroy();
  LHandler.Destroy();
end;


end.
