package model;

/**
 * Feedback model – customer rating + comment for a vendor order.
 * Matches the 'feedback' table.
 */
public class Feedback {

    private int    id;
    private int    customerId;
    private int    vendorId;
    private int    orderId;
    private int    rating;
    private String comments;
    private String createdAt;

    // Joined fields
    private String customerName;
    private String vendorShopName;

    public Feedback() {}

    public int    getId()             { return id; }
    public void   setId(int id)       { this.id = id; }

    public int    getCustomerId()               { return customerId; }
    public void   setCustomerId(int c)          { this.customerId = c; }

    public int    getVendorId()              { return vendorId; }
    public void   setVendorId(int v)         { this.vendorId = v; }

    public int    getOrderId()               { return orderId; }
    public void   setOrderId(int o)          { this.orderId = o; }

    public int    getRating()              { return rating; }
    public void   setRating(int r)         { this.rating = r; }

    public String getComments()                { return comments; }
    public void   setComments(String c)        { this.comments = c; }

    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getCustomerName()                    { return customerName; }
    public void   setCustomerName(String customerName) { this.customerName = customerName; }

    public String getVendorShopName()                        { return vendorShopName; }
    public void   setVendorShopName(String vendorShopName)   { this.vendorShopName = vendorShopName; }
}
