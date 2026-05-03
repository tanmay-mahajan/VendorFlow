package model;

/**
 * User model – represents customers, vendors, and admins.
 * Matches the 'users' table in PostgreSQL.
 */
public class User {

    private int    id;
    private String name;
    private String email;
    private String password;
    private String phone;
    private String role;          // "customer" | "vendor" | "admin"
    private String shopName;      // vendors only
    private String shopAddress;   // vendors only
    private String createdAt;

    // ------- Constructors -------

    public User() {}

    public User(int id, String name, String email, String phone,
                String role, String shopName, String shopAddress) {
        this.id          = id;
        this.name        = name;
        this.email       = email;
        this.phone       = phone;
        this.role        = role;
        this.shopName    = shopName;
        this.shopAddress = shopAddress;
    }

    // ------- Getters & Setters -------

    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }

    public String getName()              { return name; }
    public void   setName(String name)   { this.name = name; }

    public String getEmail()               { return email; }
    public void   setEmail(String email)   { this.email = email; }

    public String getPassword()                  { return password; }
    public void   setPassword(String password)   { this.password = password; }

    public String getPhone()               { return phone; }
    public void   setPhone(String phone)   { this.phone = phone; }

    public String getRole()              { return role; }
    public void   setRole(String role)   { this.role = role; }

    public String getShopName()                { return shopName; }
    public void   setShopName(String shopName) { this.shopName = shopName; }

    public String getShopAddress()                   { return shopAddress; }
    public void   setShopAddress(String shopAddress) { this.shopAddress = shopAddress; }

    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", name=" + name + ", role=" + role + "}";
    }
}
