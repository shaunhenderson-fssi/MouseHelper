unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    lblCoords: TLabel;
    lblColor: TLabel;
    Timer1: TTimer;
    lblCoords2: TLabel;
    lblColor2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    FMagnifier: TPaintBox;
    FMagnifierBuffer: TBitmap;
    FLastMagnifierPosition: TPoint;
    FHasMagnifierImage: Boolean;
    function GetPixelColor(X, Y: Integer): TColor;
    function ColorToHex(Color: TColor): string;
    procedure UpdateMagnifier(const P: TPoint);
    procedure PaintMagnifier(Sender: TObject);
    procedure MakeClickThrough;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
  end;

var
  Form1: TForm1;

const
  DISTANCEFROMMOUSE = 30;
  MAGNIFIER_SOURCE_SIZE = 7;
  MAGNIFIER_SCALE = 5;
  MAGNIFIER_SIZE = MAGNIFIER_SOURCE_SIZE * MAGNIFIER_SCALE;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Width := 120;
  Height := 100;

  FMagnifier := TPaintBox.Create(Self);
  FMagnifier.Parent := Self;
  FMagnifier.SetBounds(8, 52, MAGNIFIER_SIZE + 8, MAGNIFIER_SIZE + 8);
  FMagnifier.OnPaint := PaintMagnifier;

  FMagnifierBuffer := TBitmap.Create;
  FMagnifierBuffer.PixelFormat := pf24bit;
  FMagnifierBuffer.SetSize(FMagnifier.Width, FMagnifier.Height);
  FMagnifierBuffer.Canvas.Brush.Color := clFuchsia;
  FMagnifierBuffer.Canvas.FillRect(FMagnifierBuffer.Canvas.ClipRect);
  FHasMagnifierImage := False;

  RegisterHotKey(Handle, 1, MOD_CONTROL or MOD_SHIFT, Ord('Q')); //Ctrl+Shift+Q to quit, in case Esc does not work

  MakeClickThrough;
end;

procedure TForm1.UpdateMagnifier(const P: TPoint);
var
  ScreenDC: HDC;
  ImageRect: TRect;
begin
  FMagnifierBuffer.Canvas.Brush.Color := clFuchsia;
  FMagnifierBuffer.Canvas.FillRect(FMagnifierBuffer.Canvas.ClipRect);

  ScreenDC := GetDC(0);
  if ScreenDC = 0 then
    RaiseLastOSError;
  try
    SetStretchBltMode(FMagnifierBuffer.Canvas.Handle, COLORONCOLOR);
    if not StretchBlt(
      FMagnifierBuffer.Canvas.Handle,
      4,
      4,
      MAGNIFIER_SIZE,
      MAGNIFIER_SIZE,
      ScreenDC,
      P.X - MAGNIFIER_SOURCE_SIZE div 2,
      P.Y - MAGNIFIER_SOURCE_SIZE div 2,
      MAGNIFIER_SOURCE_SIZE,
      MAGNIFIER_SOURCE_SIZE,
      SRCCOPY
    ) then
      RaiseLastOSError;
  finally
    ReleaseDC(0, ScreenDC);
  end;

  FMagnifierBuffer.Canvas.Pen.Color := clSilver;
  FMagnifierBuffer.Canvas.Pen.Width := 1;
  FMagnifierBuffer.Canvas.Brush.Style := bsClear;
  ImageRect := Rect(3, 3, MAGNIFIER_SIZE + 5, MAGNIFIER_SIZE + 5);
  FMagnifierBuffer.Canvas.Rectangle(ImageRect);

  FMagnifierBuffer.Canvas.Pen.Color := clYellow;
  FMagnifierBuffer.Canvas.Pen.Width := 1;
  ImageRect := Rect(
    4 + (MAGNIFIER_SOURCE_SIZE div 2) * MAGNIFIER_SCALE,
    4 + (MAGNIFIER_SOURCE_SIZE div 2) * MAGNIFIER_SCALE,
    4 + (MAGNIFIER_SOURCE_SIZE div 2 + 1) * MAGNIFIER_SCALE,
    4 + (MAGNIFIER_SOURCE_SIZE div 2 + 1) * MAGNIFIER_SCALE
  );
  FMagnifierBuffer.Canvas.Rectangle(ImageRect);
  FMagnifierBuffer.Canvas.Brush.Style := bsSolid;

  FLastMagnifierPosition := P;
  FHasMagnifierImage := True;
  FMagnifier.Invalidate;
end;

procedure TForm1.PaintMagnifier(Sender: TObject);
begin
  if not BitBlt(
    FMagnifier.Canvas.Handle,
    0,
    0,
    FMagnifierBuffer.Width,
    FMagnifierBuffer.Height,
    FMagnifierBuffer.Canvas.Handle,
    0,
    0,
    SRCCOPY
  ) then
    RaiseLastOSError;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FMagnifierBuffer.Free;
  UnregisterHotKey(Handle, 1);
end;

procedure TForm1.WMHotKey(var Msg: TWMHotKey);
begin
  Close;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TForm1.MakeClickThrough;
var
  ExStyle: LongInt;
begin
  ExStyle := GetWindowLong(Handle, GWL_EXSTYLE);

  SetWindowLong(
    Handle,
    GWL_EXSTYLE,
    ExStyle or WS_EX_TRANSPARENT or WS_EX_LAYERED
  );
end;

function TForm1.GetPixelColor(X, Y: Integer): TColor;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetPixel(DC, X, Y);
  finally
    ReleaseDC(0, DC);
  end;
end;

function TForm1.ColorToHex(Color: TColor): string;
var
  RGB: COLORREF;
begin
  RGB := ColorToRGB(Color);

  Result := Format('#%.2x%.2x%.2x',
  [
    GetRValue(RGB),
    GetGValue(RGB),
    GetBValue(RGB)
  ]);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  P: TPoint;
  C: TColor;
  NewLeft: Integer;
  NewTop: Integer;
  ScreenW: Integer;
  ScreenH: Integer;
begin
  GetCursorPos(P);

  C := GetPixelColor(P.X, P.Y);

  lblCoords.Caption := Format('%d, %d', [P.X, P.Y]);
  lblColor.Caption := ColorToHex(C);
  lblCoords2.Caption := Format('%d, %d', [P.X, P.Y]);
  lblColor2.Caption := ColorToHex(C);

  if not FHasMagnifierImage or
    (P.X <> FLastMagnifierPosition.X) or
    (P.Y <> FLastMagnifierPosition.Y) then
    UpdateMagnifier(P);

  ScreenW := Screen.DesktopWidth;
  ScreenH := Screen.DesktopHeight;

  NewLeft := P.X + DISTANCEFROMMOUSE;
  NewTop := P.Y + DISTANCEFROMMOUSE;

  if NewLeft + Width > ScreenW then
    NewLeft := P.X - Width - DISTANCEFROMMOUSE;

  if NewTop + Height > ScreenH then
    NewTop := P.Y - Height - DISTANCEFROMMOUSE;

  if (Left <> NewLeft) or (Top <> NewTop) then
    SetBounds(NewLeft, NewTop, Width, Height);

end;

end.
