package model;

/**
 * CartItem – a transient item held in HTTP session cart.
 * NOT stored in DB; serialised into session as a Map.
 */
public class CartItem {

    private int    menuItemId;
    private String menuItemName;
    private double unitPrice;
    private int    quantity;
    private int    vendorId;
    private String vendorShopName;

    public CartItem() {}

    public CartItem(int menuItemId, String menuItemName, double unitPrice,
                    int quantity, int vendorId, String vendorShopName) {
        this.menuItemId     = menuItemId;
        this.menuItemName   = menuItemName;
        this.unitPrice      = unitPrice;
        this.quantity       = quantity;
        this.vendorId       = vendorId;
        this.vendorShopName = vendorShopName;
    }

    public double getSubtotal() { return unitPrice * quantity; }

    public int    getMenuItemId()                    { return menuItemId; }
    public void   setMenuItemId(int menuItemId)      { this.menuItemId = menuItemId; }

    public String getMenuItemName()                        { return menuItemName; }
    public void   setMenuItemName(String menuItemName)     { this.menuItemName = menuItemName; }

    public double getUnitPrice()                { return unitPrice; }
    public void   setUnitPrice(double unitPrice){ this.unitPrice = unitPrice; }

    public int    getQuantity()               { return quantity; }
    public void   setQuantity(int quantity)   { this.quantity = quantity; }

    public int    getVendorId()              { return vendorId; }
    public void   setVendorId(int vendorId)  { this.vendorId = vendorId; }

    public String getVendorShopName()                      { return vendorShopName; }
    public void   setVendorShopName(String vendorShopName) { this.vendorShopName = vendorShopName; }
}
