unit UParseJSON;

interface

// @define uses
uses
  Windows, Dialogs, SysUtils, Variants, Classes, System.JSON;

type
  TParseJSON = class(TObject)
    // @private
    private

    // @public
    public
      function getValue(
        fJSONValue: string;
        fUserValue: string;
        fFieldValue: string
      ) : string;

    // @public
    public
      constructor Create;
      destructor Destroy;
  end;

// @define implementation
implementation

{ TParseJSON }

// @TParseJSON::Create
constructor TParseJSON.Create;
begin
end;

// @TParseJSON::getValue
function TParseJSON.getValue(
  fJSONValue: string;
  fUserValue: string;
  fFieldValue: string
) : string;
var JSONValue: TJSonValue;
var JSONArray: TJSONArray;
var ArrayElement: TJSonValue;
var FindValue: TJSonValue;
begin
  // @define TJSONObject::ParseJSONValue
  JSONValue := TJSONObject.ParseJSONValue( fJSONValue );

  Result := JSONValue.GetValue<string>( fUserValue );

  {
  // @define JSONValue::GetValue
  JSONArray := JSONValue.GetValue<TJSONArray>( 'users' );

  // @define for ArrayElement
  for ArrayElement in JSONArray do begin
    if ArrayElement.GetValue<string>( 'user' ) = fUserValue then begin
      ShowMessage( ArrayElement.GetValue<String>( fFieldValue ));
    end;
  end; }
end;

// @TParseJSON::Destroy
destructor TParseJSON.Destroy;
begin
end;

end.
