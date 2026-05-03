package model;

import java.util.List;

/**
 * Order model – one customer order record.
 * Matches the 'orders' table in PostgreSQL.
 */
public class Order {

    private int    id;
    private int    customerId;
    private int    vendorId;
    private int    tokenNumber;
    private double totalAmount;
    private String status;        // Pending | Preparing | Ready | Completed | Cancelled
    private String specialNotes;
    private String createdAt;
    private String updatedAt;

    // Joined convenience fields
    private String customerName;
    private String vendorShopName;

    // Line items (populated when needed)
    private List<OrderItem> items;

    // ------- Constructors -------

    public Order() {}

    public Order(int customerId, int vendorId, int tokenNumber,
                 double totalAmount, String status) {
        this.customerId  = customerId;
        this.vendorId    = vendorId;
        this.tokenNumber = tokenNumber;
        this.totalAmount = totalAmount;
        this.status      = status;
    }

    // ------- Getters & Setters -------

    public int    getId()            { return id; }
    public void   setId(int id)      { this.id = id; }

    public int    getCustomerId()              { return customerId; }
    public void   setCustomerId(int customerId){ this.customerId = customerId; }

    public int    getVendorId()              { return vendorId; }
    public void   setVendorId(int vendorId)  { this.vendorId = vendorId; }

    public int    getTokenNumber()                 { return tokenNumber; }
    public void   setTokenNumber(int tokenNumber)  { this.tokenNumber = tokenNumber; }

    public double getAmount()               { return totalAmount; }
    public void   setAmount(double amount)  { this.totalAmount = amount; }

    public double getTotalAmount()                   { return totalAmount; }
    public void   setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus()               { return status; }
    public void   setStatus(String status)  { this.status = status; }

    public String getSpecialNotes()                    { return specialNotes; }
    public void   setSpecialNotes(String specialNotes) { this.specialNotes = specialNotes; }

    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt()                 { return updatedAt; }
    public void   setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }

    public String getCustomerName()                    { return customerName; }
    public void   setCustomerName(String customerName) { this.customerName = customerName; }

    public String getVendorShopName()                        { return vendorShopName; }
    public void   setVendorShopName(String vendorShopName)   { this.vendorShopName = vendorShopName; }

    public List<OrderItem> getItems()                  { return items; }
    public void            setItems(List<OrderItem> i) { this.items = i; }
}
