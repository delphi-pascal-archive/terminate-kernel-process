unit SD.Kernel;

interface

uses
  WinApi.Windows, System.SysUtils, System.Classes, WinApi.WinSvc;

type
  NTSTATUS = System.LongInt;

const
  STATUS_SUCCESS = NTSTATUS($00000000);


function SD_PsOpenProcess(DesiredAccess: ACCESS_MASK; ProcessId: THandle; var ProcessHandle: THandle): NTSTATUS;
{$IFDEF WIN32 }
{ Нет смысла использовать в x64, Zw функции там "не перехватываются", читай про PatchGuard и SSDT }
function SD_PsTerminateProcess(ProcessId: THandle; ExitStatus: NTSTATUS): NTSTATUS;
{$ENDIF }
function SD_ZwTerminateProcess(ProcessHandle: THandle; ExitStatus: NTSTATUS): NTSTATUS;
function SD_StartDriver: UINT;
function SD_StopDriver: UINT;
function SD_InstallDriver(DriverPath: WideString): UINT;
function SD_UnInstallDriver: UINT;
function SD_ConnectDriver: UINT;
function SD_DisconnectDriver: UINT;

implementation

var
  DriverDevice: THandle = 0;

function SD_CloseHandle(ObjectHandle: THandle): Boolean;
var
  Flags: DWORD;
begin
  Result := False;
  try
    if GetHandleInformation(ObjectHandle, Flags) then
      Result := CloseHandle(ObjectHandle);
  except
  end;
end;

function SD_DisconnectDriver: UINT;
var
  Flags: DWORD;
begin
  try
    Result := 666;
    SD_CloseHandle(DriverDevice);
    DriverDevice := 0;
  except
  end;
end;

function SD_ConnectDriver: UINT;
var
  Flags: DWORD;
begin
  try
    Result := 666;
    SD_DisconnectDriver;
    DriverDevice := CreateFileW('\\.\' + '8285046254869574546394', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, PSECURITY_DESCRIPTOR(nil), OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    Result := GetLastError;
  except
    DriverDevice := 0;
  end;
end;

function CTL_CODE(DeviceType: Integer; Func: Integer; Meth: Integer; Access: Integer): DWORD;
begin
  Result := (DeviceType shl 16) or (Access shl 14) or (Func shl 2) or (Meth);
end;

type
  TSD_ZwTerminateProcessCallbackInfo = record
    Status: NTSTATUS;
  end;

  PSD_ZwTerminateProcessCallbackInfo = ^TSD_ZwTerminateProcessCallbackInfo;

type
  TSD_ZwTerminateProcessInfo = record
    ProcessHandle: THandle;
    ExitStatus: NTSTATUS;
  end;

  PSD_ZwTerminateProcessInfo = ^TSD_ZwTerminateProcessInfo;

function SD_ZwTerminateProcess(ProcessHandle: THandle; ExitStatus: NTSTATUS): NTSTATUS;
var
  dwBytesReturned: DWORD;
  SD_ZwTerminateProcessCallbackInfo: TSD_ZwTerminateProcessCallbackInfo;
  SD_ZwTerminateProcessInfo: TSD_ZwTerminateProcessInfo;
begin
  Result := 666;
  try
    SD_ZwTerminateProcessCallbackInfo.Status := 666;
    SD_ZwTerminateProcessInfo.ProcessHandle := ProcessHandle;
    SD_ZwTerminateProcessInfo.ExitStatus := ExitStatus;

    if DeviceIoControl(DriverDevice, CTL_CODE($F100, $0902, 0, 0), @SD_ZwTerminateProcessInfo, SizeOf(TSD_ZwTerminateProcessInfo), @SD_ZwTerminateProcessCallbackInfo, SizeOf(TSD_ZwTerminateProcessCallbackInfo), dwBytesReturned, 0) then
      Result := SD_ZwTerminateProcessCallbackInfo.Status
    else
      Result := GetLastError;
  except
  end;
end;

// PsTerminateProcess
type
  TSD_PsTerminateProcessCallbackInfo = record
    Status: NTSTATUS;
  end;

  PSD_PsTerminateProcessCallbackInfo = ^TSD_PsTerminateProcessCallbackInfo;

type
  TSD_PsTerminateProcessInfo = record
    ProcessId: THandle;
    ExitStatus: NTSTATUS;
  end;

  PSD_PsTerminateProcessInfo = ^TSD_PsTerminateProcessInfo;

  { Настоящяя PsTerminateProcess использует PEPROCESS вместо ProcessId
    NTSTATUS PsTerminateProcess(__in PEPROCESS Process, __in NTSTATUS ExitStatus);
    ProcessId будет конвертирована в PEPROCESS в драйвере }
function SD_PsTerminateProcess(ProcessId: THandle; ExitStatus: NTSTATUS): NTSTATUS;
var
  dwBytesReturned: DWORD;
  SD_PsTerminateProcessCallbackInfo: TSD_PsTerminateProcessCallbackInfo;
  SD_PsTerminateProcessInfo: TSD_PsTerminateProcessInfo;
begin
  Result := 666;
  try
    SD_PsTerminateProcessCallbackInfo.Status := 666;
    SD_PsTerminateProcessInfo.ProcessId := ProcessId;
    SD_PsTerminateProcessInfo.ExitStatus := ExitStatus;

    if DeviceIoControl(DriverDevice, CTL_CODE($F100, $0903, 0, 0), @SD_PsTerminateProcessInfo, SizeOf(TSD_PsTerminateProcessInfo),
      @SD_PsTerminateProcessCallbackInfo, SizeOf(TSD_PsTerminateProcessCallbackInfo), dwBytesReturned, 0) then
      Result := SD_PsTerminateProcessCallbackInfo.Status
    else
      Result := GetLastError;
  except
  end;
end;

type
  TSD_PsOpenProcessCallbackInfo = record
    ProcessHandle: THandle;
    Status: NTSTATUS;
  end;

  PSD_PsOpenProcessCallbackInfo = ^TSD_PsOpenProcessCallbackInfo;

type
  TSD_PsOpenProcessInfo = record
    ProcessId: THandle;
    DesiredAccess: ACCESS_MASK;
  end;

  PSD_PsOpenProcessInfo = ^TSD_PsOpenProcessInfo;

function SD_PsOpenProcess(DesiredAccess: ACCESS_MASK; ProcessId: THandle; var ProcessHandle: THandle): NTSTATUS;
var
  dwBytesReturned: DWORD;
  SD_PsOpenProcessCallbackInfo: TSD_PsOpenProcessCallbackInfo;
  SD_PsOpenProcessInfo: TSD_PsOpenProcessInfo;
begin
  Result := 666;
  try
    ProcessHandle := 0;
    SD_PsOpenProcessCallbackInfo.ProcessHandle := 0;
    SD_PsOpenProcessCallbackInfo.Status := 666;
    SD_PsOpenProcessInfo.ProcessId := ProcessId;
    SD_PsOpenProcessInfo.DesiredAccess := DesiredAccess;

    if DeviceIoControl(DriverDevice, CTL_CODE($F100, $0901, 0, 0), @SD_PsOpenProcessInfo, SizeOf(TSD_PsOpenProcessInfo),
      @SD_PsOpenProcessCallbackInfo, SizeOf(TSD_PsOpenProcessCallbackInfo), dwBytesReturned, 0) then
    begin
      Result := SD_PsOpenProcessCallbackInfo.Status;
      if Result = STATUS_SUCCESS then
        ProcessHandle := SD_PsOpenProcessCallbackInfo.ProcessHandle;
    end
    else
      Result := GetLastError;
  except
  end;
end;

function SD_InstallDriver(DriverPath: WideString): UINT;
var
  hSCManager, hService: SC_HANDLE;
begin
  try
    Result := 666;
    hSCManager := 0;
    hSCManager := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);

    if hSCManager = 0 then
    begin
      Result := GetLastError;
      Exit;
    end;

    try
      hService := 0;
      hService := CreateServiceW(hSCManager,
        PWideChar('kernel'),
        PWideChar('kernel'),
        SERVICE_ALL_ACCESS,
        SERVICE_KERNEL_DRIVER,
        SERVICE_SYSTEM_START,
        SERVICE_ERROR_NORMAL,
        PWideChar(DriverPath),
        nil,
        nil,
        nil,
        nil,
        nil);

      try
        if (hService = 0) then
        begin
          Result := GetLastError;
          Exit;
        end;

        Result := GetLastError;
      finally
        CloseServiceHandle(hService);
      end;

    finally
      CloseServiceHandle(hSCManager);
    end;

  except
  end;
end;

function SD_StartDriver: UINT;
var
  hSCManager, hService: SC_HANDLE;
  lpServiceArgVectors: PWideChar;
begin
  try
    Result := 666;
    hSCManager := 0;
    hSCManager := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);
    if hSCManager = 0 then
    begin
      Result := GetLastError;
      Exit;
    end;

    try
      lpServiceArgVectors := nil;
      hService := OpenServiceW(hSCManager, PWideChar('kernel'), SERVICE_START);
      if hService = 0 then
      begin
        Result := GetLastError;
        Exit;
      end;

      try
        if not StartServiceW(hService, 0, PWideChar(lpServiceArgVectors)) then
        begin
          Result := GetLastError;
          Exit;
        end;

        Result := GetLastError;

      finally
        CloseServiceHandle(hService);
      end;

    finally
      CloseServiceHandle(hSCManager);
    end;
  except
  end;
end;

function SD_UnInstallDriver: UINT;
var
  hSCManager, hService: SC_HANDLE;
  lpServiceStatus: TServiceStatus;
begin
  try
    Result := 666;
    hSCManager := 0;
    hSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if hSCManager = 0 then
    begin
      Result := GetLastError;
      Exit;
    end;

    try
      hService := 0;
      hService := OpenService(hSCManager, PWideChar('kernel'), SERVICE_ALL_ACCESS);
      if (hService = 0) then
      begin
        Result := GetLastError;
        Exit;
      end;

      try
        if not DeleteService(hService) then
        begin
          Result := GetLastError;
          Exit;
        end;

        Result := GetLastError;
      finally
        CloseServiceHandle(hService);
      end;

    finally
      CloseServiceHandle(hSCManager);
    end;

  except
  end;
end;

function SD_StopDriver: UINT;
var
  hSCManager, hService: SC_HANDLE;
  lpServiceStatus: TServiceStatus;
begin
  try
    Result := 666;
    hSCManager := 0;
    hSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if hSCManager = 0 then
    begin
      Result := GetLastError;
      Exit;
    end;

    try
      hService := 0;
      hService := OpenService(hSCManager, PWideChar('kernel'), SERVICE_ALL_ACCESS);
      if (hService = 0) then
      begin
        Result := GetLastError;
        Exit;
      end;

      try
        if not ControlService(hService, SERVICE_CONTROL_STOP, lpServiceStatus) then
        begin
          Result := GetLastError;
          Exit;
        end;

        Result := GetLastError;
      finally
        CloseServiceHandle(hService);
      end;
    finally
      CloseServiceHandle(hSCManager);
    end;
  except
  end;
end;

end.
