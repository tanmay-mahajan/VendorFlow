package model;

/**
 * OrderItem – one line-item inside an Order.
 * Matches the 'order_items' table.
 */
public class OrderItem {

    private int    id;
    private int    orderId;
    private int    menuItemId;
    private int    quantity;
    private double unitPrice;
    private double subtotal;

    // Joined field
    private String menuItemName;

    public OrderItem() {}

    public OrderItem(int orderId, int menuItemId, int quantity, double unitPrice) {
        this.orderId     = orderId;
        this.menuItemId  = menuItemId;
        this.quantity    = quantity;
        this.unitPrice   = unitPrice;
        this.subtotal    = quantity * unitPrice;
    }

    public int    getId()              { return id; }
    public void   setId(int id)        { this.id = id; }

    public int    getOrderId()               { return orderId; }
    public void   setOrderId(int orderId)    { this.orderId = orderId; }

    public int    getMenuItemId()                  { return menuItemId; }
    public void   setMenuItemId(int menuItemId)    { this.menuItemId = menuItemId; }

    public int    getQuantity()               { return quantity; }
    public void   setQuantity(int quantity)   { this.quantity = quantity; }

    public double getUnitPrice()                { return unitPrice; }
    public void   setUnitPrice(double p)        { this.unitPrice = p; }

    public double getSubtotal()               { return subtotal; }
    public void   setSubtotal(double s)       { this.subtotal = s; }

    public String getMenuItemName()                      { return menuItemName; }
    public void   setMenuItemName(String menuItemName)   { this.menuItemName = menuItemName; }
}
