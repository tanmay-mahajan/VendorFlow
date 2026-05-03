package model;

/**
 * MenuItem model – represents a food/drink item in a vendor's menu.
 * Matches the 'menu_items' table in PostgreSQL.
 */
public class MenuItem {

    private int     id;
    private int     vendorId;
    private String  name;
    private String  description;
    private double  price;
    private String  category;
    private boolean isAvailable;
    private String  createdAt;

    // Convenience field – vendor's shop name (joined from users table)
    private String vendorShopName;

    // ------- Constructors -------

    public MenuItem() {}

    public MenuItem(int id, int vendorId, String name, String description,
                    double price, String category, boolean isAvailable) {
        this.id          = id;
        this.vendorId    = vendorId;
        this.name        = name;
        this.description = description;
        this.price       = price;
        this.category    = category;
        this.isAvailable = isAvailable;
    }

    // ------- Getters & Setters -------

    public int     getId()              { return id; }
    public void    setId(int id)        { this.id = id; }

    public int     getVendorId()              { return vendorId; }
    public void    setVendorId(int vendorId)  { this.vendorId = vendorId; }

    public String  getName()               { return name; }
    public void    setName(String name)    { this.name = name; }

    public String  getDescription()                    { return description; }
    public void    setDescription(String description)  { this.description = description; }

    public double  getPrice()               { return price; }
    public void    setPrice(double price)   { this.price = price; }

    public String  getCategory()                 { return category; }
    public void    setCategory(String category)  { this.category = category; }

    public boolean isAvailable()                      { return isAvailable; }
    public void    setAvailable(boolean isAvailable)  { this.isAvailable = isAvailable; }

    public String  getCreatedAt()                  { return createdAt; }
    public void    setCreatedAt(String createdAt)  { this.createdAt = createdAt; }

    public String  getVendorShopName()                       { return vendorShopName; }
    public void    setVendorShopName(String vendorShopName)  { this.vendorShopName = vendorShopName; }
}
