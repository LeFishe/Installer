//ISDone\\ 


; ISDoneLite: Number of Disks. (Important!)
#define NDisks 1

; ISDoneLite: Time Formats.
;  1 = 00:00:00
;  2 = x hr y min z sec
;  3 = x hours y minites z seconds

#define TiFormat 3

#define NeedSize "5000000000"
//#define Task

#define VCLStyle "Windows10Dark.vsf"

#define VCLStylesSkinPath "{localappdata}\VCLStylesSkin"
[Setup]
AppName=Total War ROME Remastered
AppVerName=2.00
DefaultDirName=C:\Games\Total War ROME Remastered
DefaultGroupName=Total War ROME Remastered
OutputDir=Output
OutputBaseFilename=Setup
VersionInfoCopyright=Le Fishe Repacks
SolidCompression=yes
#ifdef NeedSize
ExtraDiskSpaceRequired={#NeedSize}
#endif

[Registry]

[Icons]
Name: {commondesktop}\Total WAR Rome Remastered; Filename: {app}\Total War ROME REMASTERED.exe; WorkingDir: {app}; Check: CheckError

[Run]


[Files]
Source: Include\English.ini; DestDir: {tmp}; Flags: dontcopy

//Unpacking\\
Source: Include\arc.ini; DestDir: {tmp}; Flags: dontcopy
Source: Include\unarc.dll; DestDir: {tmp}; Flags: dontcopy
Source: Include\srep.exe; DestDir: {tmp}; Flags: dontcopy
Source: include\ISDone.dll; DestDir: {tmp}; Flags: dontcopy
Source: include\7z.dll; DestDir: {tmp}; Flags: dontcopy
Source: include\7z.exe; DestDir: {tmp}; Flags: dontcopy
Source: include\PrecompX.exe; DestDir: {tmp}; Flags: dontcopy
Source: include\precomp64.exe; DestDir: {tmp}; Flags: dontcopy
Source: include\precomp32.exe; DestDir: {tmp}; Flags: dontcopy
//Unpacking\\

//User Interface\\
Source: VCL Styles\VclStylesinno.dll; DestDir: {#VCLStylesSkinPath}; Flags: uninsneveruninstall
Source: VCL Styles\{#VCLStyle}; DestDir: {app}; Flags: dontcopy

[CustomMessages]
eng.ExtractedFile=Progress:
eng.Extracted=Unpacking ...
eng.CancelButton=Cancel
eng.PauseButton=Pause
eng.ResumeButton=Resume
eng.Error=Error!
eng.ElapsedTime=Elapsed Time:
eng.RemainingTime=Remaining Time:
eng.EstimatedTime=Estimated Time:
eng.AllElapsedTime=Time Taken:
eng.Speed=Speed:

[Languages]
Name: eng; MessagesFile: compiler:default.isl

[UninstallDelete]
Type: filesandordirs; Name: {app}

[Code]
//ISDone\\
const
  PCFonFLY=true;
  notPCFonFLY=false;
var
  LabelPct1,LabelCurrFileName,LabelTime1,LabelTime2,LabelTime3, LabelSpeed: TLabel;
  ISDoneProgressBar1: TNewProgressBar;
  MyCancelButton, PauseBtn: TButton;
  ISDoneCancel:integer;
  ISDoneError:boolean;

type
  TCallback = function(OveralPct,CurrentPct:integer;CurrentFile,TimeStr1,TimeStr2,TimeStr3,Speed:PAnsiChar): longword;

function ISArcExtract(InputFile, OutputPath, Password, CfgFile, WorkPath: WideString):boolean; external 'ISArcExtract@files:ISDone.dll stdcall delayload';
function ISDoneInit(WinHandle: longint; disks, timeformat: integer; callback: TCallback): boolean; external 'ISDoneInit@files:ISDone.dll stdcall';
function SuspendProc:boolean; external 'SuspendProc@files:ISDone.dll stdcall';
function ResumeProc:boolean; external 'ResumeProc@files:ISDone.dll stdcall';
function Exec2(FileName, Param: WideString;Show:boolean): boolean; external 'Exec2@files:ISDone.dll stdcall delayload';
procedure ISDoneStop; external 'ISDoneStop@files:ISDone.dll stdcall';
function ChangeLanguage(Language:WideString):boolean; external 'ChangeLanguage@files:ISDone.dll stdcall delayload';

function ProgressCallback(OveralPct,CurrentPct:integer;CurrentFile,TimeStr1,TimeStr2,TimeStr3,Speed:PAnsiChar): longword;
begin
  if OveralPct<=1000 then ISDoneProgressBar1.Position := OveralPct;
  LabelPct1.Caption := IntToStr(OveralPct div 10)+'.'+chr(48 + OveralPct mod 10) +'%';
  LabelCurrFileName.Caption:=ExpandConstant('{cm:ExtractedFile} ')+MinimizePathName(CurrentFile, LabelCurrFileName.Font, LabelCurrFileName.Width-ScaleX(100));
  LabelTime1.Caption:=ExpandConstant('{cm:ElapsedTime} ')+ TimeStr2;
  LabelTime2.Caption:=ExpandConstant('{cm:RemainingTime} ')+ TimeStr1;
  LabelTime3.Caption:=ExpandConstant('{cm:AllElapsedTime}  ')+ TimeStr3;
  LabelSpeed.Caption:=ExpandConstant('{cm:Speed}  ')+ Speed;
  Result := ISDoneCancel;
end;

procedure CancelButtonOnClick(Sender: TObject);
begin
  SuspendProc;
  if MsgBox(SetupMessage(msgExitSetupMessage), mbConfirmation, MB_YESNO) = IDYES then ISDoneCancel:=1;
  ResumeProc;
end;

procedure PauseButtonOnClick(Sender: TObject);
begin
  if TButton(Sender).Caption = ExpandConstant('{cm:PauseButton}') then begin
    TButton(Sender).Caption:= ExpandConstant('{cm:ResumeButton}');
    SuspendProc;
  end else begin
    TButton(Sender).Caption:= ExpandConstant('{cm:PauseButton}');
    ResumeProc;
  end;
end;

procedure HideControls;
begin
  WizardForm.FileNamelabel.Hide;
  ISDoneProgressBar1.Hide;
  LabelPct1.Hide;
  LabelCurrFileName.Hide;
  LabelTime1.Hide;
  LabelTime2.Hide;
  LabelSpeed.Hide;
  MyCancelButton.Hide;
  PauseBtn.Hide;
end;

procedure CreateControls;
var PBTop:integer;
begin
  PBTop:=ScaleY(50);
  ISDoneProgressBar1 := TNewProgressBar.Create(WizardForm);
  with ISDoneProgressBar1 do begin
    Parent   := WizardForm.InstallingPage;
    Height   := WizardForm.ProgressGauge.Height;
    Left     := ScaleX(0);
    Top      := PBTop;
    Width    := ScaleX(365);
    Max      := 1000;
  end;
  LabelPct1 := TLabel.Create(WizardForm);
  with LabelPct1 do begin
    Parent    := WizardForm.InstallingPage;
    AutoSize  := False;
    Left      := ISDoneProgressBar1.Width+ScaleX(5);
    Top       := ISDoneProgressBar1.Top + ScaleY(2);
    Width     := ScaleX(80);
  end;
  LabelCurrFileName := TLabel.Create(WizardForm);
  with LabelCurrFileName do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := ISDoneProgressBar1.Width+ScaleX(30);
    Left     := ScaleX(0);
    Top      := ScaleY(30);
  end;
  LabelTime1 := TLabel.Create(WizardForm);
  with LabelTime1 do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := ISDoneProgressBar1.Width div 2;
    Left     := ScaleX(0);
    Top      := PBTop + ScaleY(35);
  end;
  LabelTime2 := TLabel.Create(WizardForm);
  with LabelTime2 do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := False;
    Width    := LabelTime1.Width+ScaleX(40);
    Left     := ISDoneProgressBar1.Width div 2;
    Top      := LabelTime1.Top;
  end;
  LabelTime3 := TLabel.Create(WizardForm);
  with LabelTime3 do begin
    Parent   := WizardForm.FinishedPage;
    AutoSize := False;
    Width    := 300;
    Left     := 180;
    Top      := 200;
  end;
  LabelSpeed := TLabel.Create(WizardForm);
  with LabelSpeed do begin
    Parent   := WizardForm.InstallingPage;
    AutoSize := True;
    Width    := ScaleX(40);
    Left     := ScaleX(0);
    Top      := LabelTime1.Top + 50;
  end;
  MyCancelButton:=TButton.Create(WizardForm);
  with MyCancelButton do begin
    Parent:=WizardForm;
    Width:=ScaleX(135);
    Caption:=ExpandConstant('{cm:CancelButton}');
    Left:=ScaleX(360);
    Top:=WizardForm.cancelbutton.top;
    OnClick:=@CancelButtonOnClick;
  end;
  PauseBtn:=TButton.Create(WizardForm);
  with PauseBtn do begin
    Parent:=WizardForm;
    Caption:=ExpandConstant('{cm:PauseButton}');
    Left:=ScaleX(20);
    Top:=WizardForm.BackButton.top;
    OnClick:=@PauseButtonOnClick;
  end;
end;

Procedure CurPageChanged(CurPageID: Integer);
Begin
  if (CurPageID = wpFinished) and ISDoneError then
  begin
    LabelTime3.Hide;
    WizardForm.Caption:= ExpandConstant('{cm:Error}');
    WizardForm.FinishedLabel.Font.Color:= clRed;
    WizardForm.FinishedLabel.Caption:= SetupMessage(msgSetupAborted) ;
  end;
end;

function CheckError:boolean;
begin
  result:= not ISDoneError;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then begin
    WizardForm.ProgressGauge.Hide;
    WizardForm.CancelButton.Hide;
    CreateControls;
    WizardForm.StatusLabel.Caption:=ExpandConstant('{cm:Extracted}');
    ISDoneCancel:=0;

    // ISDoneLite: Language File.
    ExtractTemporaryFile('English.ini');

    ExtractTemporaryFile('unarc.dll');
    ExtractTemporaryFile('arc.ini');
    ExtractTemporaryFile('srep.exe');

    ISDoneError:=true;
    if ISDoneInit(MainForm.Handle, {#NDisks}, {#TiFormat}, @ProgressCallback) then begin
      repeat
        ChangeLanguage('English');
        if not ISArcExtract(ExpandConstant('{src}\data1.bf'), ExpandConstant('{app}\data1'), 'ele123', ExpandConstant('{tmp}\arc.ini'), ExpandConstant('{app}')) then break;
        if not ISArcExtract(ExpandConstant('{src}\data2.bf'), ExpandConstant('{app}\data2'), 'ele123', ExpandConstant('{tmp}\arc.ini'), ExpandConstant('{app}')) then break;
        if not ISArcExtract(ExpandConstant('{src}\data3.bf'), ExpandConstant('{app}\data3'), 'ele123', ExpandConstant('{tmp}\arc.ini'), ExpandConstant('{app}')) then break;

        ISDoneError:=false;
      until true;
      ISDoneStop;
    end;
    HideControls;
    WizardForm.CancelButton.Visible:=true;
    WizardForm.CancelButton.Enabled:=false;
  end;
  if (CurStep=ssPostInstall) and ISDoneError then begin
    Exec2(ExpandConstant('{uninstallexe}'), '/VERYSILENT', false);
  end;
end;

//VCL Styles\\

// Import the LoadVCLStyle function from VclStylesInno.DLL
procedure LoadVCLStyle(VClStyleFile: String); external 'LoadVCLStyleW@files:VclStylesInno.dll stdcall setuponly';
procedure LoadVCLStyle_UnInstall(VClStyleFile: String); external 'LoadVCLStyleW@{#VCLStylesSkinPath}\VclStylesInno.dll stdcall uninstallonly';
// Import the UnLoadVCLStyles function from VclStylesInno.DLL
procedure UnLoadVCLStyles; external 'UnLoadVCLStyles@files:VclStylesInno.dll stdcall setuponly';
procedure UnLoadVCLStyles_UnInstall; external 'UnLoadVCLStyles@{#VCLStylesSkinPath}\VclStylesInno.dll stdcall uninstallonly';

function InitializeSetup(): Boolean;
begin
	ExtractTemporaryFile('{#VCLStyle}');
	LoadVCLStyle(ExpandConstant('{tmp}\{#VCLStyle}'));
	Result := True;
end;

procedure DeinitializeSetup();
begin
	UnLoadVCLStyles;
end;

function InitializeUninstall: Boolean;
begin
  Result := True;
  LoadVCLStyle_UnInstall(ExpandConstant('{#VCLStylesSkinPath}\{#VCLStyle}'));
end;

procedure DeinitializeUninstall();
begin
  UnLoadVCLStyles_UnInstall;
end;
