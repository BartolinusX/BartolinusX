unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Menus;

type
  TForm3 = class(TForm)
    TreeView1: TTreeView;
    Button1: TButton;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    SaveasUTF8BOM1: TMenuItem;
    OznczawszystkiebezBOM1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure TreeView1Deletion(Sender: TObject; Node: TTreeNode);
    procedure SaveasUTF8BOM1Click(Sender: TObject);
    procedure TreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure OznczawszystkiebezBOM1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.Types;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    FilePath: string;
    HasBOM: Boolean;
  end;


function HasBOM(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  BOM: array[0..3] of Byte;
begin
  Result := False;
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    // Wczytaj pierwsze 4 bajty pliku
    FillChar(BOM, SizeOf(BOM), 0);
    FileStream.ReadBuffer(BOM, SizeOf(BOM));

    // Sprawdź BOM dla różnych kodowań
    if (BOM[0] = $EF) and (BOM[1] = $BB) and (BOM[2] = $BF) then
      Result := True  // UTF-8 BOM
    else if (BOM[0] = $FF) and (BOM[1] = $FE) then
      Result := True  // UTF-16 Little Endian BOM
    else if (BOM[0] = $FE) and (BOM[1] = $FF) then
      Result := True  // UTF-16 Big Endian BOM
    else if (BOM[0] = $FF) and (BOM[1] = $FE) and (BOM[2] = $00) and (BOM[3] = $00) then
      Result := True  // UTF-32 Little Endian BOM
    else if (BOM[0] = $00) and (BOM[1] = $00) and (BOM[2] = $FE) and (BOM[3] = $FF) then
      Result := True; // UTF-32 Big Endian BOM
  finally
    FileStream.Free;
  end;
end;

procedure AddFileToTreeView(Node: TTreeNode; const FileName: string);
var
  NodeData: PNodeData;
begin
  // Alokacja pamięci dla rekordu
  New(NodeData);
  NodeData^.FilePath := FileName;
  NodeData^.HasBOM := HasBOM(FileName);  // Użycie wcześniej zdefiniowanej funkcji HasBOM

  // Przypisanie rekordu do Node.Data
  Node.Data := NodeData;
end;

procedure LoadFileWithBOMToMemo(const FileName: string; Memo: TMemo);
var
  FileStream: TFileStream;
  StringStream: TStringStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  StringStream := TStringStream.Create;
  try
    // Wczytaj całą zawartość pliku do TStringStream jako surowe bajty
    StringStream.CopyFrom(FileStream, FileStream.Size);

    // Konwertuj zawartość TStringStream na tekst i dodaj do Memo
    Memo.Lines.Text := StringStream.DataString;
  finally
    StringStream.Free;
    FileStream.Free;
  end;
end;

procedure FillTreeViewWithDirectory(TreeView: TTreeView; const Directory: string; FileTypes: string);
var
  DirList, FileList: TStringDynArray;
  RootNode, ChildNode, FileNode: TTreeNode;
  Dir, FileName, FileType: string;

  FileTypesArray: TArray<string>;
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;

    FileTypesArray := FileTypes.Split([',']);
    
    // Dodanie katalogu głównego
    RootNode := TreeView.Items.Add(nil, ExtractFileName(Directory));

    // Pobieranie podkatalogów
    DirList := TDirectory.GetDirectories(Directory);
    for Dir in DirList do
    begin
      ChildNode := TreeView.Items.AddChild(RootNode, ExtractFileName(Dir));
      ChildNode.Data := nil;

      // Pobieranie plików w każdym podkatalogu
      for FileType in FileTypesArray do
      begin
        FileList := TDirectory.GetFiles(Dir, FileType);
        for FileName in FileList do
        begin
          FileNode := TreeView.Items.AddChild(ChildNode, ExtractFileName(FileName));
          AddFileToTreeView(FileNode, FileName);

          if HasBOM(FileName) then
            FileNode.Checked := True;

        end;
      end;
    end;
  finally
    TreeView.AlphaSort(True);
    TreeView.Items.EndUpdate;
    TreeView.FullExpand;
  end;
end;

procedure ConvertToUTF8WithBOM(const InputFileName, OutputFileName: string);
var
  TextFile: TStringList;
begin
  TextFile := TStringList.Create;
  try
    // Wczytaj zawartość pliku
    TextFile.LoadFromFile(InputFileName, TEncoding.Default);

    // Zapisz plik z kodowaniem UTF-8 z BOM
    TextFile.SaveToFile(OutputFileName, TEncoding.UTF8);
  finally
    TextFile.Free;
  end;
end;

procedure MarkNodesWithBOM(Node: TTreeNode);
var
  NodeData: PNodeData;
begin
  // Rekurencyjne przetwarzanie wszystkich węzłów
  while Assigned(Node) do
  begin
    // Sprawdź, czy węzeł zawiera dane pliku
    if Assigned(Node.Data) then
    begin
      NodeData := PNodeData(Node.Data);

      // Jeśli plik ma BOM, zaznacz checkbox
      if NodeData^.HasBOM then
        Node.Checked := True
      else
        Node.Checked := False;
    end;

    // Przetwórz podwęzły
    MarkNodesWithBOM(Node.GetFirstChild);

    // Przejdź do następnego rodzeństwa węzła
    Node := Node.GetNextSibling;
  end;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  FillTreeViewWithDirectory(TreeView1, 'c:\temp', '*.pas,*.dpr,*.dproj');
end;

procedure TForm3.OznczawszystkiebezBOM1Click(Sender: TObject);
var
  Node : TTreeNode;
begin
  Node := TreeView1.Items.GetFirstNode;
  if Assigned(Node) then
    MarkNodesWithBOM(TreeView1.Items.GetFirstNode);
end;

procedure TForm3.SaveasUTF8BOM1Click(Sender: TObject);
var
  SelectedNode : TTreeNode;
  NodeData: PNodeData;
begin
  SelectedNode := TreeView1.Selected;
  if Assigned(SelectedNode.Data) then
  begin
    NodeData := SelectedNode.Data;
    if not NodeData^.HasBOM then
    begin
      NodeData := PNodeData(SelectedNode.Data);
      ConvertToUTF8WithBOM(NodeData^.FilePath, NodeData^.FilePath);
      LoadFileWithBOMToMemo(NodeData^.FilePath, Memo1);
      NodeData^.HasBOM := True;
      MarkNodesWithBOM(TreeView1.Items.GetFirstNode);
    end
    else
      ShowMessage('Plik: ' + NodeData^.FilePath + ' zawiera BOM.');
  end;
end;

procedure TForm3.TreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
var
  NodeData: PNodeData;
begin
  if Assigned(Node.Data) and (Node.Data <> nil) then
  begin
    NodeData := PNodeData(Node.Data);

    // Otwórz i wyświetl zawartość pliku w Memo1
    if FileExists(NodeData^.FilePath) then
    begin
      try
        LoadFileWithBOMToMemo(NodeData^.FilePath, Memo1);
      except
        on E: Exception do
          ShowMessage('Błąd podczas otwierania pliku: ' + E.Message);
      end;
    end;
  end;
end;

procedure TForm3.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
var
  NodeData: PNodeData;
begin
  if Node.Data <> nil then
  begin
    NodeData := PNodeData(Node.Data);
    Dispose(NodeData);  // Zwolnienie pamięci
    Node.Data := nil;
  end;
end;

end.
