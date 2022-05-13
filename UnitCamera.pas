unit UnitCamera;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Media, FMX.Objects,

  ZXing.ScanManager,
  ZXing.ReadResult,
  ZXing.BarcodeFormat,
  FMX.Platform, FMX.Effects, FMX.Filter.Effects;

type
  TFrmCamera = class(TForm)
    CameraComponent: TCameraComponent;
    lbl_erro: TLabel;
    img_camera: TImage;
    img_close: TImage;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Line1: TLine;
    procedure CameraComponentSampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure FormShow(Sender: TObject);
    procedure img_closeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FScanManager : TScanManager;
    FScanInProgress : Boolean;
    FFrameTake : Integer;
    procedure ProcessarImagem;
    { Private declarations }
  public
    { Public declarations }
    codigo : string;

 t: TThread;
  end;

var
  FrmCamera: TFrmCamera;

implementation

{$R *.fmx}

procedure TFrmCamera.FormCreate(Sender: TObject);
begin
    FScanManager := TScanManager.Create(TBarcodeFormat.Auto, nil);
end;

procedure TFrmCamera.FormDestroy(Sender: TObject);
begin
    FScanManager.DisposeOf;
end;

procedure TFrmCamera.FormShow(Sender: TObject);


begin

    t.CreateAnonymousThread(procedure
    begin

       t.Synchronize(nil,procedure
       begin
         FFrameTake := 7;
        CameraComponent.Active := false;
        CameraComponent.Kind := TCameraKind.BackCamera;
        CameraComponent.FocusMode := TFocusMode.ContinuousAutoFocus;
        CameraComponent.Quality := TVideoCaptureQuality.MediumQuality;
        CameraComponent.Active := true;


       end);
    end).start;;





end;

procedure TFrmCamera.img_closeClick(Sender: TObject);
begin
    CameraComponent.Active := false;

    close;
end;

procedure TFrmCamera.ProcessarImagem;
var
    bmp : TBitmap;
    ReadResult : TReadResult;

begin

      CameraComponent.SampleBufferToBitmap(img_camera.Bitmap, true);

      t.CreateAnonymousThread(procedure
    begin





      t.Synchronize(nil,procedure
      begin



        if FScanInProgress then
            exit;

        inc(FFrameTake);

        if (FFrameTake mod 4 <> 0) then
            exit;

        bmp := TBitmap.Create;
        bmp.Assign(img_camera.Bitmap);
        ReadResult := nil;

        try
            FScanInProgress := true;

            try
                ReadResult := FScanManager.Scan(bmp);

                if ReadResult <> nil then
                begin
                    CameraComponent.Active := true;
                    codigo := ReadResult.text;
                    close;
                end;

            except on ex:exception do
                lbl_erro.Text := ex.Message;
            end;
        finally
            bmp.DisposeOf;
            ReadResult.DisposeOf;
            FScanInProgress := false;

        end;

       end);
    end).start;





end;

procedure TFrmCamera.CameraComponentSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);

begin

    t.CreateAnonymousThread(procedure
    begin

       t.Synchronize(nil,procedure
       begin
          ProcessarImagem;
       end);
    end).start;


end;

end.
