import Toybox.Lang;
import Toybox.WatchUi;

/*
 * Base class for all primitive sitemap elements—those that do not 
 * contain other elements.
 *
 * Examples of primitive elements: `Switch`, `Text`
 * Examples of container elements: `Homepage`, `Frame`
 */
class SitemapPrimitiveElement extends SitemapElement {

    // JSON field names
    private const ITEM = "item";
    private const ITEM_NAME = "name";
    private const ITEM_TYPE = "type";
    private const ITEM_STATE = "state";

    // Fields read from the JSON
    public var itemName as String;
    public var itemState as String;
    public var itemType as String;
    
    // For some elements, the widget label also contains state information,
    // which may include mappings and formatting. This state is extracted
    // into this member and removed from the label.
    public var widgetState as String?;

    // The label may include a state in the format:
    //   label [state]
    // This function parses the input into the actual label and the state,
    // returning both as a tuple: [0] = label, [1] = state.
    private function parseLabel( fullLabel as String ) as [String, String?] {
        var widgetLabel = fullLabel;
        var widgetState = null;
        var bracket = label.find( " [" ) as Number?;
        if( bracket != null ) {
            widgetLabel = label.substring( null, bracket ) as String?;
            if( widgetLabel == null ) {
                throw new JsonParsingException( "Label '" + label + "' does not have label before the [state]" );
            }
            widgetState = label.substring( bracket+2, label.length()-1 ) as String?;
        }
        return [widgetLabel, widgetState];
    }

    // Constructor
    protected function initialize( data as JsonObject ) {
        // First initialize the super class
        // We need the label from the super class before continuing
        SitemapElement.initialize( data );

        // For some elements, the label includes a state in the format:
        //   label [state]
        // We split the two, storing the actual label in the `label` member
        // and the state in `widgetState`.
        var parsedLabel = parseLabel( label );
        label = parsedLabel[0];
        widgetState = parsedLabel[1];

        // ... and then read all the elements
        var item =  getObject( data, ITEM, "Element '" + label + "': no item found" );
        itemName =  getString( item, ITEM_NAME, "Element '" + label + "': item has no name" );
        itemType =  getString( item, ITEM_TYPE, "Element '" + label + "': item has no type" );
        itemState = getString( item, ITEM_STATE, "Element '" + label + "': item has no state" );
    }
}