library DBISAM3_lib;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  DB,
  DBISAMTb,
  superobject,
  DateUtils,
  EncryptU in '..\Common Code\Classes\EncryptU.pas';

{$R *.res}

function SaveStringToFile(aString: PChar): Boolean; stdcall;
var
  aList: TStringList;
begin
  try
    aList := TStringList.Create;
    try
      aList.Text := aString;
      aList.SaveToFile('DBISAM3_dll_test.txt');
      Result := True;
    finally
      aList.Free;
    end;
  except
    Result := False;
  end
end;

procedure WriteLog(aString: string);
var
  aList: TStringList;
  aPath: string;
begin
  aList := TStringList.Create;
  try
    aPath := ExtractFilePath(GetModuleName(hInstance)) + 'DBISAM3_DLL_ERRORS\';
    if ForceDirectories(aPath) then
      begin
        aList.Text := aString;
        aList.SaveToFile(aPath + 'DBISAM3_dll_error_' + FormatDateTime('yyyy-mm-dd_hh-nn-ss-zzz', Now) + '.txt');
      end
    else
      begin
        aList.Text := aString;
        aList.SaveToFile('DBISAM3_dll_last_error.txt');
      end;
  finally
    aList.Free;
  end;
end;

procedure WriteActionLog(aString, actionName: string);
var
  aList: TStringList;
  aPath: string;
begin
  aList := TStringList.Create;
  try
    aPath := ExtractFilePath(GetModuleName(hInstance)) + 'DBISAM3_DLL_ACTIONS\';
    if ForceDirectories(aPath) then
      begin
        aList.Text := aString;
        aList.SaveToFile(aPath + actionName + FormatDateTime('yyyy-mm-dd_hh-nn-ss-zzz', Now) + '.txt');
      end;
  finally
    aList.Free;
  end;
end;


procedure CreateDBComponents(aDatabasePath: PChar; var database: TDBISAMDatabase; var
    dbSesion: TDBISAMSession; var qAction, qAction1, qAction2: TDBISAMQuery);
var
  aSesionName: string;
  aSeesionTempPath, aPos: string;
begin
  try
    aPos := 'GetGUIDU';
    aSesionName := EncryptU.GetGUIDU;

    aPos := 'TDBISAMSession.Create';
    dbSesion := TDBISAMSession.Create(nil);
    dbSesion.SessionType := stLocal;
    dbSesion.LockProtocol := lpPessimistic;
    dbSesion.KeepConnections := True;
    dbSesion.SessionName := aSesionName;
    dbSesion.LockWaitTime := 100;
    dbSesion.Active := True;

    aPos := 'TDBISAMDatabase.Create';
    database := TDBISAMDatabase.Create(nil);
    database.DatabaseName := EncryptU.GetGUIDU;
    database.SessionName := aSesionName;
    database.Directory := aDatabasePath; // database path

    aPos := 'ExtractFilePath';
    aSeesionTempPath := ExtractFilePath(GetModuleName(hInstance)) + 'DBISAM3_TEMP\';

    aPos := 'ForceDirectories';
    if ForceDirectories(aSeesionTempPath) then
      database.Session.PrivateDir := aSeesionTempPath
    else
      database.Session.PrivateDir := aDatabasePath;

    database.KeepConnection := True;
    database.Connected := True;

    aPos := 'qAction.Create';
    qAction := TDBISAMQuery.Create(nil);
    qAction.SessionName := aSesionName;
    qAction.DatabaseName := database.DatabaseName;

    aPos := 'qAction1.Create';
    qAction1 := TDBISAMQuery.Create(nil);
    qAction1.SessionName := aSesionName;
    qAction1.DatabaseName := database.DatabaseName;

    aPos := 'qAction2.Create';
    qAction2 := TDBISAMQuery.Create(nil);
    qAction2.SessionName := aSesionName;
    qAction2.DatabaseName := database.DatabaseName;
  except
    on E : Exception do
      begin
        raise Exception.Create(E.Message + ' Position: ' + aPos);
      end;
  end;
end;

procedure CreateDBComponents_1(aDatabasePath: PChar; var database:
    TDBISAMDatabase; var dbSesion: TDBISAMSession; var qAction: TDBISAMQuery);
var
  aSesionName: string;
  aSeesionTempPath, aPos: string;
begin
  try
    aPos := 'GetGUIDU';
    aSesionName := EncryptU.GetGUIDU;

    aPos := 'TDBISAMSession.Create';
    dbSesion := TDBISAMSession.Create(nil);
    dbSesion.SessionType := stLocal;
    dbSesion.LockProtocol := lpPessimistic;
    dbSesion.KeepConnections := True;
    dbSesion.SessionName := aSesionName;
    dbSesion.LockWaitTime := 100;
    dbSesion.Active := True;

    aPos := 'TDBISAMDatabase.Create';
    database := TDBISAMDatabase.Create(nil);
    database.DatabaseName := EncryptU.GetGUIDU;
    database.SessionName := aSesionName;
    database.Directory := aDatabasePath; // database path

    aPos := 'ExtractFilePath';
    aSeesionTempPath := ExtractFilePath(GetModuleName(hInstance)) + 'DBISAM3_TEMP\';

    aPos := 'ForceDirectories';
    if ForceDirectories(aSeesionTempPath) then
      database.Session.PrivateDir := aSeesionTempPath
    else
      database.Session.PrivateDir := aDatabasePath;

    database.KeepConnection := True;
    database.Connected := True;

    aPos := 'qAction.Create';
    qAction := TDBISAMQuery.Create(nil);
    qAction.SessionName := aSesionName;
    qAction.DatabaseName := database.DatabaseName;
  except
    on E : Exception do
      begin
        raise Exception.Create('CreateDBComponents_1: ' + E.Message + ' Position: ' + aPos);
      end;
  end;
end;

function WriteToDBISAM3(aAction, aDatabasePath, aTable, idFieldName,
    aRecordJson, aBlobFieldName, aFilePath: PChar): PChar; stdcall;
var
  ResultString: AnsiString;
  aKey, aFieldsForSQL: string;
  i, i1: Integer;
  aFields, aBlobFields, aValues, aValuesForUpdate, aFieldsParams: TStringList;

  aEmptyStream: TMemoryStream;
  aJSONArray: ISuperObject;
  //aSesionName, aSeesionTempPath: string;

  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  qAction1: TDBISAMQuery;
  qAction2: TDBISAMQuery;
begin
  try
    CreateDBComponents(aDatabasePath, database,  dbSesion, qAction, qAction1, qAction2);

    aJSONArray := SO(aRecordJson);
    aFields := TStringList.Create;
    aBlobFields := TStringList.Create;
    aFieldsParams := TStringList.Create;
    aValues := TStringList.Create;
    aValuesForUpdate := TStringList.Create;
    aEmptyStream := TMemoryStream.Create;

    //WriteLog(aRecordJson);
    try
      //Getting list of table fields
      with qAction1 do
        begin
          Close;
          SQL.Clear;
          SQL.Add('Select * from ' + aTable + '');
          SQL.Add('Top 1');
          Open;

          for i := 0 to Fields.Count -1 do
            begin
              if aJSONArray.AsArray[0].O[Fields.Fields[i].FieldName] <> nil then
                begin
                  if aJSONArray.AsArray[0].S[Fields.Fields[i].FieldName] <> 'null' then
                    begin
                      if aFieldsForSQL = '' then
                        aFieldsForSQL := '"' + (Fields.Fields[i].FieldName) + '"'
                      else
                        aFieldsForSQL := aFieldsForSQL + ',"' + (Fields.Fields[i].FieldName) + '"';

                      aFieldsParams.Add(':' + Fields.Fields[i].FieldName);

                      if Fields.Fields[i].DataType = ftBlob then
                        begin
                          aBlobFields.Add(Fields.Fields[i].FieldName);
                         // WriteLog('Blob Field ' + Fields.Fields[i].FieldName);
                        end
        //              else if (Fields.Fields[i].DataType = ftMemo) and (Fields.Fields[i].FieldName = 'JSON') then
        //                begin
        //                  aBlobFields.Add(Fields.Fields[i].FieldName);
        //                end
                      else
                        begin
                          aFields.Add(Fields.Fields[i].FieldName);
                        end;
                    end;
                end;
            end;
        end;

      ///Assigning Field value from JSON based on field name. Fields in local table and JSON have to be identical.
      database.StartTransaction;

      try
        //aStart := Now;

        if aAction = 'insert' then
          begin
            with qAction1 do
              begin
                SQL.Clear;
                SQL.Add('Insert into ' + aTable + ' (' + aFieldsForSQL + ')');
                SQL.Add('Values (' + aFieldsParams.CommaText + ')');
                Prepare;
              end;
          end;

        for i := 0 to aJSONArray.AsArray.Length -1 do
          begin
            aValues.Clear;
            aValuesForUpdate.Clear;
            aKey := '';

            if aAction = 'update' then
              begin
                aFieldsParams.Clear;

                for i1 := 0 to aFields.Count -1 do
                  begin
                    if (aFields[i1] = idFieldName) then    //'Key'
                      aKey := aJSONArray.AsArray[i].S[aFields[i1]]
                    else
                      begin
                        try
                          aValuesForUpdate.Add(aJSONArray.AsArray[i].S[aFields[i1]]);
                          aFieldsParams.Add(aFields[i1]);

                          if aValues.Text = '' then
                            aValues.Add('"' + aFields[i1]  + '" = :' + aFields[i1])
                          else
                            aValues.Add(', "' + aFields[i1]  + '" = :' + aFields[i1])
                        except
                          on E : Exception do
                            begin
                              WriteLog('Adding Values. Part "update". WriteToDBISAM3  ' + aTable + ' ' + E.ClassName  + ' ' + E.Message);
                              ResultString := 'failed to update DBISAM3 table record';
                              Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
                              StrPCopy(Result, ResultString);
                              raise;
                            end;
                        end;
                      end;
                  end;

                for i1 := 0 to aBlobFields.Count -1 do
                  begin
                    if aValues.Text = '' then
                      aValues.Add(aBlobFields[i1]  + ' = :' + aBlobFields[i1])
                    else
                      aValues.Add(', ' + aBlobFields[i1]  + ' = :' + aBlobFields[i1])
                  end;
              end;

            ///Insert or update table
            if aAction = 'insert' then
              begin
                with qAction1 do
                  begin
                    for i1 := 0 to aFields.Count -1 do
                      begin
                        ParamByName('' + aFields[i1] + '').AsString := aJSONArray.AsArray[i].S[aFields[i1]];
                      end;

                    for i1 := 0 to aBlobFields.Count -1 do
                      begin
                        if aBlobFieldName <> '' then
                          begin
                            if UpperCase(aBlobFields[i1]) = UpperCase(aBlobFieldName) then
                              begin
                                if FileExists(aFilePath) then
                                  ParamByname('' + aBlobFields[i1] + '').LoadFromFile(aFilePath, ftBlob)
                                else
                                  ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                              end
                            else
                              begin
                                ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                              end;
                          end
                        else
                          begin
                            //If parameter aBlobFieldName is empty nothing will be inserted to it
                            ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                          end;
                      end;

                    ExecSQL;
                  end;
              end
            else if aAction = 'update' then
              begin
                with qAction2 do
                  begin
                    SQL.Clear;
                    SQL.Add('Update ' + aTable + '');
                    SQL.Add('Set ' + aValues.Text + '');
                    SQL.Add('where ' + idFieldName + ' = :Key');
                    ParamByName('Key').AsString := aKey;

                    for i1 := 0 to aFieldsParams.Count -1 do
                      begin
                        ParamByName('' + aFieldsParams[i1] + '').AsString := aValuesForUpdate[i1];
                      end;

                    for i1 := 0 to aBlobFields.Count -1 do
                      begin
                        if aBlobFieldName <> '' then
                          begin
                            if UpperCase(aBlobFields[i1]) = UpperCase(aBlobFieldName) then
                              begin
                                if FileExists(aFilePath) then
                                  ParamByname('' + aBlobFields[i1] + '').LoadFromFile(aFilePath, ftBlob)
                                else
                                  ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                              end
                            else
                              begin
                                ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                              end;
                          end
                        else
                          begin
                            //If parameter aBlobFieldName is empty nothing will be inserted to it
                            ParamByname('' + aBlobFields[i1] + '').LoadFromStream(aEmptyStream, ftBlob);
                          end;
                      end;

                    ExecSQL;
                  end;
              end;
          end;

        database.Commit;


        ResultString := 'OK';
        WriteActionLog('WriteToDBISAM3 result ' + ResultString, 'WriteToDBISAM3');
        Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
        StrPCopy(Result, ResultString);
      except
        on E : Exception do
          begin
            database.Rollback;
//            if aAction = 'insert' then
//              WriteLog('WriteToDBISAM3 writing ' + aTable + ' ' + E.ClassName  + ' ' + E.Message + '  ' + qAction1.SQL.Text)
//            else
//              WriteLog('WriteToDBISAM3 updating ' + aTable + ' ' + E.ClassName  + ' ' + E.Message + '  ' + qAction2.SQL.Text);

            ResultString := 'failed';
            Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
            StrPCopy(Result, ResultString);
            raise;
          end;
      end;
    finally
      FreeAndNil(qAction);
      FreeAndNil(qAction1);
      FreeAndNil(qAction2);
      FreeAndNil(database);
      FreeAndNil(dbSesion);

      aFields.Free;
      aBlobFields.Free;
      aFieldsParams.Free;
      aValues.Free;
      aValuesForUpdate.Free;
      aEmptyStream.Free;
    end;
  except
    on E : Exception do
      begin
        if aAction = 'insert' then
          ResultString := 'failed inserting record to DBISAM3 table ' + aTable +  '  ' +  E.Message
        else
          ResultString := 'failed to update DBISAM3 record in table ' + aTable + '  ' + E.Message;

        Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
        StrPCopy(Result, ResultString);
        WriteLog('WriteToDBISAM3 main ' + aTable + ' ' + E.ClassName  + ' ' + E.Message  + '  ' + aRecordJson);
      end;
  end
end;

function ReadDBISAM3Permissions(aDatabasePath, aProjectDbPath, aUserRef, aProjectRef: PChar):
    PChar; stdcall;
var
  companyRef: string;
  ResultString: AnsiString;
  aJSONArray, aJSON: ISuperObject;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  qAction1: TDBISAMQuery;
  qAction2: TDBISAMQuery;
begin
  try
    CreateDBComponents(aDatabasePath, database,  dbSesion, qAction, qAction1, qAction2);
    aJSONArray := SA([]);

    try
      with qAction1 do
        begin
          Close;
          SQL.Clear;
          SQL.Add('Select PermissionName, R, W, D from UserPermissions');
          SQL.Add('where UserRef = :UserRef and PermissionName = :PermissionName and ProjectRef = :ProjectRef and Deleted <> True');
          ParamByName('UserRef').AsString := aUserRef;
          ParamByName('ProjectRef').AsString := aProjectRef;
          ParamByName('PermissionName').AsString := 'ASSETSMANAGEMENT';
          Open;
          First;

          if RecordCount > 0 then
            begin
              while not Eof do
                begin
                  aJSON := SO;

                  aJSON.S['PermissionName'] := FieldByName('PermissionName').AsString;
                  aJSON.B['R'] := FieldByName('R').AsBoolean;
                  aJSON.B['W'] := FieldByName('W').AsBoolean;
                  aJSON.B['D'] := FieldByName('D').AsBoolean;

                  aJSONArray.AsArray.Add(aJSON);
                  Next;
                end;
            end
          else
            begin
              Close;
              SQL.Clear;
              SQL.Add('Select CompanyRef from "'+aProjectDbPath+'\insp_ProjectTeam"');
              SQL.Add('Where UserRef = :UserRef and CompanyRef <> null and Ref = null and Deleted <> True');
              ParamByName('UserRef').AsString := aUserRef;
              Open;
              First;

              if FieldByName('CompanyRef').AsString <> '' then
                begin
                  companyRef := FieldByName('CompanyRef').AsString;

                  Close;
                  SQL.Clear;
                  SQL.Add('Select PermissionName, R, W, D from UserPermissions');
                  SQL.Add('where UserRef = :UserRef and PermissionName = :PermissionName and ProjectRef = :ProjectRef and Deleted <> True');
                  ParamByName('UserRef').AsString := companyRef;
                  ParamByName('ProjectRef').AsString := aProjectRef;
                  ParamByName('PermissionName').AsString := 'ASSETSMANAGEMENT';
                  Open;
                  First;

                  if RecordCount > 0 then
                    begin
                      while not Eof do
                        begin
                          aJSON := SO;

                          aJSON.S['PermissionName'] := FieldByName('PermissionName').AsString;
                          aJSON.B['R'] := FieldByName('R').AsBoolean;
                          aJSON.B['W'] := FieldByName('W').AsBoolean;
                          aJSON.B['D'] := FieldByName('D').AsBoolean;

                          aJSONArray.AsArray.Add(aJSON);
                          Next;
                        end;
                    end;
                end

            end;
        end;

      //WriteLog('Permissions result ' + aJSONArray.AsJson  + '  companyRef =' + companyRef + '  aProjectDbPath =' + aProjectDbPath + '  aUserRef =' + aUserRef + '  aDatabasePath =' + aDatabasePath + '  aProjectRef =' + aProjectRef);

      ResultString := aJSONArray.AsJson;
      WriteActionLog('ReadDBISAM3Permissions result ' + ResultString, 'ReadDBISAM3Permissions');
      Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
      StrPCopy(Result, ResultString);
    finally
      FreeAndNil(qAction);
      FreeAndNil(qAction1);
      FreeAndNil(qAction2);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error ReadDBISAM3Permissions main  ' + E.ClassName  + ' ' + E.Message);
      end;
  end
end;

function UpdateDBISAM3EquipmentTable(aDatabasePath: PChar):
    PChar; stdcall;
var
  aFieldsForSQL: string;
  ResultString: AnsiString;
  i, i1: Integer;
  aFields, aBlobFields, aValues, aValuesForUpdate, aFieldsParams: TStringList;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  qAction1: TDBISAMQuery;
  qAction2: TDBISAMQuery;
begin
  try
    CreateDBComponents(aDatabasePath, database,  dbSesion, qAction, qAction1, qAction2);

    try
      with qAction do
        begin
          Close;
          SQL.Clear;
          SQL.ADD('Select * from Equipment Top 1');
          Open;

          if FindField('IsVerified') = nil then
            begin
              Close;
              SQL.Clear;
              SQL.ADD('Alter Table Equipment Add IsVerified Boolean Default False;');
              ExecSQL;
              Close;
              //WriteLog('Table "' + aDatabasePath + 'Equipment" altered');
            end;
        end;

      ResultString := 'OK';
      WriteActionLog('UpdateDBISAM3EquipmentTable result ' + ResultString, 'UpdateDBISAM3EquipmentTable');
      Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
      StrPCopy(Result, ResultString);
    finally
      FreeAndNil(qAction);
      FreeAndNil(qAction1);
      FreeAndNil(qAction2);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error UpdateDBISAM3EquipmentTable  ' + E.ClassName  + ' ' + E.Message);
      end;
  end
end;

function GetSafetyFilePath(aDatabasePath, aTable, aRecordID: PChar):
    PChar; stdcall;
var
  ResultString: AnsiString;
  i, i1: Integer;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  aPos: string;
begin
  try
    aPos := 'Creating DB Components';
    CreateDBComponents_1(aDatabasePath, database,  dbSesion, qAction);

    aPos := 'Run SQL';
    try
      with qAction do
        begin
          Close;
          SQL.Clear;

          if LowerCase(aTable) = 'documents' then
            begin
              aPos := 'Run SQL: add sql string for documents table';
              SQL.Add('Select PDFLink, Subfolder from '+aTable+'');
              SQL.Add('where DocumentID = :aRecordID');
              ParamByName('aRecordID').AsInteger := StrToInt(aRecordID);
              aPos := 'Run SQL: open documents table';
              Open;

              aPos := 'Run SQL: write results of documents table';
              ResultString := FieldByName('Subfolder').AsString + FieldByName('PDFLink').AsString;
            end
          else if LowerCase(aTable) = 'drawings' then
            begin
              aPos := 'Run SQL: add sql string for drawings table';
              SQL.Add('Select Link as PDFLink, Subfolder from '+aTable+'');
              SQL.Add('where DrawingID = :aRecordID');
              ParamByName('aRecordID').AsInteger := StrToInt(aRecordID);
              aPos := 'Run SQL: open drawings table';
              Open;

              aPos := 'Run SQL: write results of drawings table';
              ResultString := FieldByName('Subfolder').AsString + FieldByName('PDFLink').AsString;
            end
          else if LowerCase(aTable) = LowerCase('WorkOrdersAttachments') then
            begin
              aPos := 'Run SQL: add sql string for WorkOrdersAttachments table';
              SQL.Add('Select FilePath from '+aTable+'');
              SQL.Add('where ID = :aRecordID');
              ParamByName('aRecordID').AsInteger := StrToInt(aRecordID);
              aPos := 'Run SQL: open WorkOrdersAttachments table';
              Open;

              aPos := 'Run SQL: write results of WorkOrdersAttachments table';
              ResultString := FieldByName('FilePath').AsString;
            end
          else if LowerCase(aTable) = LowerCase('commentAttachments') then
            begin
              aPos := 'Run SQL: add sql string for commentAttachments table';
              SQL.Add('Select FilePath from '+aTable+'');
              SQL.Add('where CommentRef = :CommentRef');
              ParamByName('CommentRef').AsString := aRecordID;
              aPos := 'Run SQL: open commentAttachments table';
              Open;

              aPos := 'Run SQL: write results of commentAttachments table';
              ResultString := FieldByName('FilePath').AsString;
            end;

          //WriteLog('GetSafetyFilePath result ' + ResultString);
          WriteActionLog('GetSafetyFilePath result ' + ResultString, 'GetSafetyFilePath');
          aPos := 'Return Result';
          Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
          StrPCopy(Result, ResultString);
          aPos := 'Free Resources';
        end;
    finally
      FreeAndNil(qAction);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error GetSafetyFilePath main  ' + E.ClassName  + ' ' + E.Message + #13#10 +
          'Params: DBPath ' + aDatabasePath + #13#10 +
          'Table ' + aTable + #13#10 +
          'RecordID ' +  aRecordID + #13#10 +
          'Error Position: ' + aPos);
      end;
  end
end;

function GetQRCodeStatus(aDatabasePath, aTable, aRecordID: PChar):
    PChar; stdcall;
var
  aFieldsForSQL: string;
  ResultString: AnsiString;
  i, i1: Integer;
  aFields, aBlobFields, aValues, aValuesForUpdate, aFieldsParams: TStringList;
  aEmptyStream: TMemoryStream;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  qAction1: TDBISAMQuery;
  qAction2: TDBISAMQuery;
begin
  try
    CreateDBComponents(aDatabasePath, database,  dbSesion, qAction, qAction1, qAction2);

    try
      with qAction1 do
        begin
          if FileExists(aDatabasePath + 'QRCodeControl.dat') then
            begin
              Close;
              SQL.Clear;
              SQL.Add('SELECT Key, OpenQRCode FROM QRCodeControl');
              SQL.Add('Where Upper(Type) = :Type and RecordRef = :RecordRef and Deleted <> True');
              ParamByName('Type').AsString := UpperCase(aTable);
              ParamByName('RecordRef').AsString := aRecordID;
              Open;

              if FieldByName('Key').AsString <> '' then
                begin
                  if FieldByName('OpenQRCode').AsBoolean then
                    ResultString := 'true'
                  else
                    ResultString := 'false';
                end;
            end;

          if ResultString = '' then
            begin
              if FileExists(aDatabasePath + 'WebSettings.dat') then
                begin
                  Close;
                  SQL.Clear;
                  SQL.Add('SELECT * FROM WebSettings');
                  Open;

                  if FindField('OpenQRCode') <> nil then
                    begin
                      if FieldByName('OpenQRCode').AsBoolean then
                        ResultString := 'true'
                      else
                        ResultString := 'false';
                    end
                  else
                    ResultString := 'No OpenQRCode field in WebSettings table.'
                end;
            end;

          WriteActionLog('GetQRCodeStatus result ' + ResultString, 'GetQRCodeStatus');
          Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
          StrPCopy(Result, ResultString);
        end;
    finally
      FreeAndNil(qAction);
      FreeAndNil(qAction1);
      FreeAndNil(qAction2);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        ResultString := E.Message;
        Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
        StrPCopy(Result, ResultString);
        WriteLog('Error GetQRCodeStatus  ' + E.ClassName  + ' ' + E.Message);
      end;
  end
end;

function GetTableInfo(aProjectDbPath, aTable: PChar):
    PChar; stdcall;
var
  companyRef: string;
  ResultString: AnsiString;
  aJSON: ISuperObject;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  qAction1: TDBISAMQuery;
  qAction2: TDBISAMQuery;
begin
  try
    CreateDBComponents(aProjectDbPath, database, dbSesion, qAction, qAction1, qAction2);
    aJSON := SO;

    try
      if not FileExists(aProjectDbPath + '\' + aTable + '.dat') then
        begin
          ResultString := 'NoTable';
          Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
          StrPCopy(Result, ResultString);
          Exit;
        end;

      with qAction do
        begin
          aJSON.S['TableName'] := aTable;

          if UpperCase(aTable) = UpperCase('DatabaseInfo') then
            begin
              Close;
              SQL.Clear;
              SQL.Add('SELECT Version FROM '+aTable+'');
              Open;
              Last;
              aJSON.S['DatabaseVersion'] := FieldByName('Version').AsString;
            end
          else
            begin
              Close;
              SQL.Clear;
              SQL.Add('SELECT Count(*) as Counted FROM '+aTable+'');
              SQL.Add('WHERE Deleted <> True');
              Open;

              aJSON.I['RecordsCount'] := FieldByName('Counted').AsInteger;

              SQL.Clear;
              SQL.Add('SELECT Modified FROM '+aTable+'');
              SQL.Add('WHERE Deleted <> True');
              SQL.Add('ORDER BY Modified DESC');
              SQL.Add('TOP 1');
              Open;

              if RecordCount > 0 then
                aJSON.S['LastModified'] := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', FieldByName('Modified').AsDateTime)
              else
                aJSON.S['LastModified'] := '';
            end;

          Close;
        end;

      //WriteLog('Permissions result ' + aJSONArray.AsJson  + '  companyRef =' + companyRef + '  aProjectDbPath =' + aProjectDbPath + '  aUserRef =' + aUserRef + '  aDatabasePath =' + aDatabasePath + '  aProjectRef =' + aProjectRef);

      ResultString := aJSON.AsJson;
      WriteActionLog('GetTableInfo result ' + ResultString, 'GetTableInfo');
      Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
      StrPCopy(Result, ResultString);
    finally
      FreeAndNil(qAction);
      FreeAndNil(qAction1);
      FreeAndNil(qAction2);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error GetTableInfo main  ' + E.ClassName  + ' ' + E.Message + ' ' + aProjectDbPath + '  '+ aTable);
      end;
  end
end;

function ExportTableToCSV(aProjectDbPath, aTable, outputFolder, typesList: PChar):
    PChar; stdcall;
var
  ResultString: AnsiString;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  outputFile: string;
  aList: TStringList;
begin
  try
    CreateDBComponents_1(aProjectDbPath, database,  dbSesion, qAction);
    outputFile := outputFolder + '\' + aTable + '.csv';

    try
      if not FileExists(aProjectDbPath + '\' + aTable + '.dat') then
        begin
          WriteLog('Error ExportTableToCSV main  ' + ' ' + aProjectDbPath + '  '+ aTable);
          ResultString := 'NoTable';
          Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
          StrPCopy(Result, ResultString);
          Exit;
        end;

      with qAction do
        begin
          Close;
          SQL.Clear;

          SQL.Add('SELECT * FROM '+aTable+'');
          SQL.Add('WHERE Deleted <> True');

          if typesList <> '' then
            begin
              SQL.Add('and Modified > :Modified and Type in ('+typesList+')');
              ParamByName('Modified').AsDateTime := IncDay(Now, -14);
            end;

          Open;

          ExportTable(
            outputFile,
            ',',
            True,
            nil,
            'yyyy-mm-dd',
            'HH:mm:ss.zzz'
          );

          Close;

          if UpperCase(aTable) = 'INSP_FORMS' then
            begin
              aList := TStringList.Create;
              try
                aList.LoadFromFile(outputFile);
                aList.Text := StringReplace(aList.Text, ',RecordID,', ',_RecordID,', [rfReplaceAll, rfIgnoreCase]);
                aList.SaveToFile(outputFile);
              finally
                aList.Free;
              end;
            end;
        end;

      ResultString := 'OK';
      WriteActionLog('ExportTableToCSV result ' + ResultString, 'ExportTableToCSV');
      Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
      StrPCopy(Result, ResultString);
    finally
      FreeAndNil(qAction);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error ExportTableToCSV main  ' + E.ClassName  + ' ' + E.Message + ' ' + aProjectDbPath + '  '+ aTable);
      end;
  end
end;

function ExportFormsToCSV(aProjectDbPath, aTable, outputFolder, filterString,
    olderRecordsThanDays: PChar): PChar; stdcall;
var
  ResultString: AnsiString;
  database: TDBISAMDatabase;
  dbSesion: TDBISAMSession;
  qAction: TDBISAMQuery;
  outputFile: string;
  aList: TStringList;
  aSQLString: string;
begin
  try
    CreateDBComponents_1(aProjectDbPath, database,  dbSesion, qAction);
    outputFile := outputFolder + '\' + aTable + '.csv';

    try
      if not FileExists(aProjectDbPath + '\' + aTable + '.dat') then
        begin
          WriteLog('Error ExportTableToCSV main  ' + ' ' + aProjectDbPath + '  '+ aTable);
          ResultString := 'NoTable';
          Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
          StrPCopy(Result, ResultString);
          Exit;
        end;

      with qAction do
        begin
          Close;
          SQL.Clear;

          SQL.Add('SELECT Key, Code, Replace(#10 with '' '' in  Replace(#13  with '' '' in Caption)) as Caption, Type, ProjectRef, Notify, Status, SourceRef, Created, Modified  FROM '+aTable+'');
          SQL.Add('WHERE Deleted <> True');
          SQL.Add('and Modified > :Modified '+filterString+'');
          ParamByName('Modified').AsDateTime := IncDay(Now, StrToIntDef(olderRecordsThanDays, -10));
          aSQLString := SQL.Text;
          Open;

          ExportTable(
            outputFile,
            ',',
            True,
            nil,
            'yyyy-mm-dd',
            'HH:mm:ss.zzz'
          );

          Close;

          if UpperCase(aTable) = 'INSP_FORMS' then
            begin
              aList := TStringList.Create;
              try
                aList.LoadFromFile(outputFile);
                aList.Text := StringReplace(aList.Text, ',RecordID,', ',_RecordID,', [rfReplaceAll, rfIgnoreCase]);
                aList.SaveToFile(outputFile);
              finally
                aList.Free;
              end;
            end;
        end;

      ResultString := 'OK';
      WriteActionLog('ExportFormsToCSV result ' + ResultString, 'ExportFormsToCSV' );
      Result := StrAlloc(Length(ResultString) + 1);  // Allocate memory
      StrPCopy(Result, ResultString);
    finally
      FreeAndNil(qAction);
      FreeAndNil(database);
      FreeAndNil(dbSesion);
    end;
  except
    on E : Exception do
      begin
        Result := '';
        WriteLog('Error ExportFormsToCSV main  ' + E.ClassName  + ' ' + E.Message + ' ' + aProjectDbPath + '  '+ aTable +  #13+#10 + aSQLString);
      end;
  end
end;

exports
  SaveStringToFile;

exports
  WriteToDBISAM3;

exports
  ReadDBISAM3Permissions;

exports
  UpdateDBISAM3EquipmentTable;

exports
  GetSafetyFilePath;

exports
  GetQRCodeStatus;

exports
  GetTableInfo;

exports
  ExportTableToCSV;

exports
  ExportFormsToCSV;

begin
end.
