import Toybox.Lang;
import Toybox.WatchUi;

/*
 * Base class for all menu items that represent `Switch` sitemap elements.
 */
class SwitchMenuItem extends BaseSitemapMenuItem {
    // The openHAB item linked to the sitemap element
    private var _itemName as String;
    public function getItemName() as String {
        return _itemName;
    }

    // The command request for sending commands
    // Defined as interface, since two types of command requests are supported
    private var _commandRequest as CommandRequestInterface?;

    // Abstract functions to be implemented by subclasses
    // getNextCommand() shall return the command to be triggered
    // when the menu item is selected
    public function getNextCommand() as String {
        throw new AbstractMethodException( "SwitchMenuItem.getNextCommand" );
    }
    // updateItemState() shall update the state Drawable with a new state
    public function updateItemState( state as String ) as Void {
        throw new AbstractMethodException( "SwitchMenuItem.updateItemState" );
    }
    
    // Constructor
    protected function initialize( sitemapSwitch as SitemapSwitch, statusDrawable as Drawable ) {
        _itemName = sitemapSwitch.itemName;
        BaseSitemapMenuItem.initialize(
            {
                :id => sitemapSwitch.id,
                :label => sitemapSwitch.label,
                :status => statusDrawable
            }
        );
        
        // Depending on the settings, either a native REST API command request 
        // or a custom Webhook command request is instantiated.
        // If neither is configured, no command request is created, and items 
        // will only display their current state.
        if( AppSettings.supportsRestApi() ) {
            _commandRequest = new NativeCommandRequest( self );
        } else if( AppSettings.supportsWebhook() ) {
            _commandRequest = new WebhookCommandRequest( self );
        }
    }


    // `onSelect()` retrieves the command from the subclass and sends it.
    // The new state is stored in `_newState` and only applied after the request succeeds.
    private var _newState as String?;
    public function onSelect() as Void {
        if( _newState == null && _commandRequest != null ) {
            _newState = getNextCommand();
            ( _commandRequest as WebhookCommandRequest ).sendCommand( _newState );
        }
    }
    
    // Called by the command request after the command is successfully sent.
    // Triggers `updateItemState()` for the subclass to update the state `Drawable`,
    // and then requests a UI redraw.
    public function onCommandComplete() as Void {
        if( _newState != null ) {
            updateItemState( _newState );
            _newState = null;
            WatchUi.requestUpdate();
        }
    }

    // Called by the command request if an error occurred.
    // The `_newState` will not be applied.
    public function onException( ex as Exception ) as Void {
        _newState = null;
    }

    // Called by the sitemap request when updated state data is received.
    // Updates the label and delegates status `Drawable` updates to the subclass.
    public function update( sitemapElement as SitemapElement ) as Boolean {
        var sitemapSwitch = sitemapElement as SitemapSwitch;
        setCustomLabel( sitemapSwitch.label );
        updateItemState( sitemapSwitch.itemState );
        return true;
    }
}
