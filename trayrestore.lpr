program trayrestore;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, Windows, Messages
  { you can add units after this };

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure ClearDeadIcons; virtual;
  end;

{ TMyApplication }

function NextWindow(wnd:LongWord; list:LongInt): LongBool; stdcall;
var
  WM_TASKBAR_CREATED: Cardinal;
begin
  WM_TASKBAR_CREATED := RegisterWindowMessage('TaskbarCreated');
  SendMessage(wnd, WM_TASKBAR_CREATED, 0, 0);
  result := true;
end;

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  ClearDeadIcons;
  EnumWindows(@NextWindow, 0);
  writeln('All possible tray icons have been restored.');

  // stop program loop
  Terminate;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TMyApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName);
  writeln('This application restores icons of running applications to the tray in the case of Explorer crashing.');
  writeln('');
  writeln('Copyright (c) 2013 Owen Winkler  http://owenw.com');
  writeln('');
  writeln('Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:');
  writeln('');
  writeln('The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.');
  writeln('');
  writeln('THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.');
end;

procedure TMyApplication.ClearDeadIcons;
var
  wnd : cardinal;
  rec : TRect;
  w,h : integer;
  x,y : integer;
begin
  // find a handle of a tray
  wnd := FindWindow('Shell_TrayWnd', nil);
  wnd := FindWindowEx(wnd, 0, 'TrayNotifyWnd', nil);
  wnd := FindWindowEx(wnd, 0, 'SysPager', nil);
  wnd := FindWindowEx(wnd, 0, 'ToolbarWindow32', nil);

  // get client rectangle (needed for width and height of tray)
  windows.GetClientRect(wnd, rec);

  // get size of small icons
  w := GetSystemMetrics(sm_cxsmicon);
  h := GetSystemMetrics(sm_cysmicon);

  // initial y position of mouse - half of height of icon
  y := w shr 1;
  while y < rec.Bottom do begin // while y < height of tray
    x := h shr 1; // initial x position of mouse - half of width of icon
    while x < rec.Right do begin // while x < width of tray
      SendMessage(wnd, wm_mousemove, 0, y shl 16 or x); // simulate moving mouse over an icon
      x := x + w; // add width of icon to x position
    end;
    y := y + h; // add height of icon to y position
  end;
end;

var
  Application: TMyApplication;
begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='My Application';
  Application.Run;
  Application.Free;
end.

