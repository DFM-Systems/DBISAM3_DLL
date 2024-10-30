unit DataMain;

interface

uses
  SysUtils, Classes, DB, DBISAMTb;

type
  TDataModule1 = class(TDataModule)
    DBISAMSession1: TDBISAMSession;
    DBISAMQuery1: TDBISAMQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.dfm}

end.
