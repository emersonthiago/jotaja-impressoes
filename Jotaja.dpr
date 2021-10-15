program Jotaja;

uses
  Vcl.Forms,
  UPrinterServers in 'UPrinterServers.pas' {JotajaPedidos},
  UHttpRequest in 'Units\UHttpRequest.pas',
  UParseJSON in 'Units\UParseJSON.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Jotaja Pedidos';
  Application.CreateForm(TJotajaPedidos, JotajaPedidos);
  Application.Run;
end.
