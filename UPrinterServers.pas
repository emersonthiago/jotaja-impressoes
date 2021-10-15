unit UPrinterServers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdMultipartFormData,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, UHttpRequest, UParseJSON,
  Vcl.ExtCtrls, Vcl.Buttons, IniFiles, ShellAPI, Vcl.Imaging.jpeg, Vcl.Menus;

type
  TJotajaPedidos = class(TForm)
    GBUsername: TGroupBox;
    editUsername: TEdit;
    editPasswd: TEdit;
    lbUsername: TLabel;
    lbPasswd: TLabel;
    btnAutenticar: TButton;
    PLAutentication: TPanel;
    GPConfiguracaoAPI: TGroupBox;
    editAutenticacaoAPI: TEdit;
    lbAPIDesc: TLabel;
    editCupomFiscalAPI: TEdit;
    Label3: TLabel;
    GBConfiguracaoImpressao: TGroupBox;
    editDiretorioCompartilhado: TEdit;
    Label1: TLabel;
    editTempoInterval: TEdit;
    Label2: TLabel;
    btnSalvarConfiguracao: TButton;
    btnMinimizar: TButton;
    GPTimer: TPanel;
    Image1: TImage;
    btnParar: TButton;
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    Abrir1: TMenuItem;
    Encerrar1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarConfiguracaoClick(Sender: TObject);
    procedure btnAutenticarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure btnMinimizarClick(Sender: TObject);
    procedure Encerrar1Click(Sender: TObject);
    procedure Abrir1Click(Sender: TObject);
    procedure ShowTest1Click(Sender: TObject);
  public
    { Public declarations }
    function currentDirectory( fFilename: String ): string;
    procedure confimation( fText: string );
    procedure information( fText: string );
    procedure error( fText: string );
    procedure startAPI;
    procedure startAPIOnTimer(Sender: TObject);
    procedure startAPIOnClock(Sender: TObject);
  private
    { Private declarations }
    iniFile: TIniFile;
    procedure initConfig;
    procedure initComponents;
  public
    { Public declarations }
  end;

var
  JotajaPedidos: TJotajaPedidos;
  JotajaToken: String;
  JotajaTimer: TTimer;
  JotajaClock: TTimer;
  JotajaReport: TStrings;
  JotajaStarted: Boolean;

implementation


{$R *.dfm}

// TeditDiretorioImpressao.FormCreate
procedure TJotajaPedidos.FormCreate(Sender: TObject);
begin
  // InitConfig
  initConfig();
  initComponents();

  // Start Rotina de Checagem de Cupom
  btnAutenticar.Click;
end;

// TeditDiretorioImpressao.currentDirectory
function TJotajaPedidos.currentDirectory( fFilename: String ): string;
begin
  Result := ExtractFileDir( GetCurrentDir()) + '\Debug\' + fFilename;
end;

procedure TJotajaPedidos.Encerrar1Click(Sender: TObject);
begin
  // Encerrar Aplicação
  if MessageDlg( 'Deseja fechar o sistema?',
    TMsgDlgType.mtConfirmation, [
      TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel
    ], 0 ) = mrOk then
  begin
    Application.Terminate;
  end;
end;

// TeditDiretorioImpressao.error
procedure TJotajaPedidos.error( fText: string );
begin
  // Autentication
  PLAutentication.Caption := fText;
  PLAutentication.Color := clRed;
  PLAutentication.Font.Color := clWhite;
end;

// TeditDiretorioImpressao.information
procedure TJotajaPedidos.information( fText: string );
begin
  // Autentication
  PLAutentication.Caption := fText;
  PLAutentication.Color := clSilver;
  PLAutentication.Font.Color := clWhite;
end;

// TeditDiretorioImpressao.confimation
procedure TJotajaPedidos.confimation( fText: string );
begin
  // Autentication
  PLAutentication.Caption := fText;
  PLAutentication.Color := clGreen;
  PLAutentication.Font.Color := clWhite;
end;

// TeditDiretorioImpressao.startAPI
procedure TJotajaPedidos.startAPI;
begin
  // Redinifir RunTimers
  JotajaTimer.Interval := StrToInt( editTempoInterval.Text );
end;

// TeditDiretorioImpressao.startAPIOnTimer
procedure TJotajaPedidos.startAPIOnTimer(Sender: TObject);
var idMultipartFormData: TIdMultiPartFormDataStream;
var iHttpRequest: THttpRequest;
var iParseJSON: TParseJSON;
var iJSONData: string;
begin
  if JotajaStarted then
  begin

    // Clear Lines
    JotajaReport.Clear;

    // information
    information( 'Buscando Cupoms na API' );

    // Button Parar
    btnParar.Caption := 'Parar';

    // Replicar ProcessMessages
    Application.ProcessMessages;

    // Autentication Exemplo's
    // @define idMultipartFormData
    idMultipartFormData := TIdMultiPartFormDataStream.Create;
    idMultipartFormData.AddFormField( 'token', JotajaToken );

    // Enviar Posts
    iHttpRequest := THttpRequest.Create( editCupomFiscalAPI.Text );
    iJSONData := iHttpRequest.Post( idMultipartFormData );

    // Validar Session
    if iParseJSON.getValue( iJSONData, 'success', '' ) = 'false' then begin
      error( 'Error: ' + iParseJSON.getValue( iJSONData, 'content', '' ));
    end else begin

      // Mostrar Messsagem de Confirmação de Autenticação
      confimation( 'Cupom encontrado com sucesso!' );

      // Definir Messagem Baloon
      TrayIcon.BalloonFlags := bfInfo;
      TrayIcon.BalloonTitle := 'Jotaja Serviço';
      TrayIcon.BalloonHint  := 'Jotaja Impressão de Cupom';
      TrayIcon.BalloonTimeout := 2000;
      TrayIcon.ShowBalloonHint();

      // Replicar ProcessMessages
      Application.ProcessMessages;

      // Add Reports
      JotajaReport.add( iParseJSON.getValue( iJSONData, 'content', '' ));

      // Save to file
      JotajaReport.SaveToFile( editDiretorioCompartilhado.Text + Format( '\%s_%s.imp', [
        'imprimir', FormatDateTime( 'dd_mm_yyyy_hh_mm_ss', now())
      ]));
    end;
  end else
  begin
    // Button Parar
    btnParar.Caption := 'Iniciar';
  end;
end;

// TeditDiretorioImpressao.startAPIOnClock
procedure TJotajaPedidos.startAPIOnClock(Sender: TObject);
begin
  // Replicar ProcessMessages
  Application.ProcessMessages;

  // Update Timers
  GPTimer.Caption := DateTimeToStr( now());
end;

// TeditDiretorioImpressao.btnSalvarConfiguracaoClick
procedure TJotajaPedidos.Abrir1Click(Sender: TObject);
begin
  // Minimizar Events
  JotajaPedidos.Show();
  JotajaPedidos.WindowState := wsNormal;

  // Events TrayIcon
  TrayIcon.Visible := False;
  TrayIcon.Animate := False;

  // Trazer para Frente
  Application.BringToFront();
end;

procedure TJotajaPedidos.btnAutenticarClick(Sender: TObject);
var idMultipartFormData: TIdMultiPartFormDataStream;
var iHttpRequest: THttpRequest;
var iParseJSON: TParseJSON;
var iJSONData: string;
begin
  // information
  information( 'Autenticando...' );

  // Replicar ProcessMessages
  Application.ProcessMessages;

  // Autentication Exemplo's
  // @define idMultipartFormData
  idMultipartFormData := TIdMultiPartFormDataStream.Create;
  idMultipartFormData.AddFormField( 'username', editUsername.Text );
  idMultipartFormData.AddFormField( 'passwd', editPasswd.Text );

  // Open Request
  iHttpRequest := THttpRequest.Create( editAutenticacaoAPI.Text );
  iJSONData := iHttpRequest.Post( idMultipartFormData );

  // Validar Session
  if iParseJSON.getValue( iJSONData, 'success', '' ) = 'false' then begin
    error( 'Error: ' + iParseJSON.getValue( iJSONData, 'content', '' ));
  end else begin
    // Mostrar Messsagem de Confirmação de Autenticação
    confimation( 'Autenticação realizada com sucesso!' );

    // Validar Session ID
    JotajaToken := iParseJSON.getValue( iJSONData, 'content', '' );

    // Habilitar Button Parar Or Start
    btnParar.Enabled := True;
    btnParar.Caption := 'Parar';

    // Desabilitar Button Autenticação
    btnAutenticar.Enabled := False;

    // Start Rotina
    JotajaStarted := True;

    // Start Rotina de Checagem de Cupom
    startAPI;
  end;
end;


// TeditDiretorioImpressao.initConfig
procedure TJotajaPedidos.initConfig;
begin
  // Modificar para not start
  JotajaStarted := False;

  // Verificar se Exists initConfig
  if FileExists( currentDirectory( 'config.cfg' )) = false then begin
    iniFile := TIniFile.Create( currentDirectory( 'config.cfg' ));
    // Session API
    iniFile.WriteString( 'API', 'url_autenticacao', 'https://seusite/api_autenticacao' );
    iniFile.WriteString( 'API', 'url_cupom_fiscal', 'https://seusite/api_cumpo_fiscal' );
    // Session Auth
    iniFile.WriteString( 'Auth', 'username', 'usuario_autenticacao' );
    iniFile.WriteString( 'Auth', 'passwd', 'password_autenticacao' );
    // Session Print
    iniFile.WriteString( 'Print', 'diretorio_compartilhamento', '\\diretorio\compartatilhamento' );
    iniFile.WriteString( 'Print', 'interval', '3000' );
  end else begin
    // Somente abrir o arquivo
    iniFile := TIniFile.Create( currentDirectory( 'config.cfg' ));
  end;
end;

procedure TJotajaPedidos.ShowTest1Click(Sender: TObject);
begin
  TrayIcon.ShowBalloonHint();
end;

// TeditDiretorioImpressao.initComponents
procedure TJotajaPedidos.initComponents;
begin
  // Edit Session API
  editAutenticacaoAPI.Text := iniFile.ReadString( 'API', 'url_autenticacao', '' );
  editCupomFiscalAPI.Text := iniFile.ReadString( 'API', 'url_cupom_fiscal', '' );
  // Edit Session Auth
  editUsername.Text := iniFile.ReadString( 'Auth', 'username', '' );
  editPasswd.Text := iniFile.ReadString( 'Auth', 'passwd', '' );
  // Edit Session Print
  editDiretorioCompartilhado.Text := iniFile.ReadString( 'Print', 'diretorio_compartilhamento', '' );
  editTempoInterval.Text := iniFile.ReadString( 'Print', 'interval', '' );

  // Create StringList
  JotajaReport := TStringList.Create;

  // Timer Created's
  JotajaTimer := TTimer.Create(nil);
  JotajaTimer.Interval := 0;
  JotajaTimer.OnTimer := startAPIOnTimer;

  // JotajaClock Created's
  JotajaClock := TTimer.Create(nil);
  JotajaClock.Interval := 1000;
  JotajaClock.OnTimer := startAPIOnClock;
end;

procedure TJotajaPedidos.btnMinimizarClick(Sender: TObject);
begin
  // Minimizar Events
  JotajaPedidos.Hide();
  JotajaPedidos.WindowState := wsMinimized;

  // Events TrayIcon
  TrayIcon.Visible := True;
  TrayIcon.Animate := True;
  TrayIcon.ShowBalloonHint;
end;

procedure TJotajaPedidos.btnPararClick(Sender: TObject);
begin
  // Definir Evento de Parar Or a Rotina de Impressão
  if btnParar.Enabled = True then
  begin
    if JotajaStarted then
    begin
      JotajaStarted := False;

      // Replicar ProcessMessages
      Application.ProcessMessages;

      // Messagem de Rotina Stop
      confimation( 'Rotina de Impressão Interrompida.' );

    end else
      // Parar
      JotajaStarted := True;

      // Replicar ProcessMessages
      Application.ProcessMessages;

      // Messagem de Rotina Stop
      information( 'Rotina de Impressão Inicializada.' );
    end;
end;

procedure TJotajaPedidos.btnSalvarConfiguracaoClick(Sender: TObject);
begin
  // Session API
  iniFile := TIniFile.Create( currentDirectory( 'config.cfg' ));
  iniFile.WriteString( 'API', 'url_autenticacao', editAutenticacaoAPI.Text );
  iniFile.WriteString( 'API', 'url_cupom_fiscal', editCupomFiscalAPI.Text );
  // Session Auth
  iniFile.WriteString( 'Auth', 'username', editUsername.Text );
  iniFile.WriteString( 'Auth', 'passwd', editPasswd.Text );
  // Session Print
  iniFile.WriteString( 'Print', 'diretorio_compartilhamento', editDiretorioCompartilhado.Text );
  iniFile.WriteString( 'Print', 'interval', editTempoInterval.Text );

  // Messagem de Confirmação
  MessageDlg( 'Configurações salvas com sucesso!', mtInformation, [ mbOk ], 0 );
end;
end.
