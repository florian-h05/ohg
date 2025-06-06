import Toybox.Lang;
import Toybox.WatchUi;

/*
 * Menu item implementation for `Text` sitemap elements.
 * The text status is displayed in the status field of BaseSitemapMenuItem.
 * The status is extracted from the sitemap element's label, which contains
 * both the label text and the status enclosed in square brackets.
 * This approach is preferred over retrieving the status from the associated item,
 * as the embedded status includes any formatting defined for the sitemap text element.
 */
class TextMenuItem extends BaseSitemapMenuItem {
    
    // The text status Drawable
    private var _statusTextArea as TextStatusDrawable;

    private function checkState( sitemapText as SitemapText ) as Void {
        if( sitemapText.widgetState == null ) {
            throw new JsonParsingException( "Text element '" + sitemapText.label + "' does not contain [state] in its label" );
        }
    }

    // Constructor
    public function initialize( sitemapText as SitemapText ) {
        checkState( sitemapText );
        _statusTextArea = new TextStatusDrawable( sitemapText.label, sitemapText.widgetState as String );
        BaseSitemapMenuItem.initialize(
            {
                :id => sitemapText.id,
                :label => sitemapText.label,
                :status => _statusTextArea
            }
        );
    }

    // Updates the menu item
    public function update( sitemapElement as SitemapElement ) as Boolean {
        if( ! ( sitemapElement instanceof SitemapText ) ) {
            throw new GeneralException( "Sitemap element '" + sitemapElement.label + "' was passed into TextMenuItem but is of a different type" );
        }
        var sitemapText = sitemapElement as SitemapText;
        checkState( sitemapText );
        _statusTextArea.update( sitemapElement.label, sitemapElement.widgetState as String  );
        setCustomLabel( sitemapElement.label );
        return true;
    }

    // Returns true if the given sitemap element matches the type handled by this menu item.
    public static function isMyType( sitemapElement as SitemapElement ) as Boolean {
        return sitemapElement instanceof SitemapText; 
    }
}
