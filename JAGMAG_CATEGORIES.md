# Jagmag - Streetlight & Infrastructure Categories

## 🏗️ **Recommended Categories for Jagmag App**

Based on the streetlight and infrastructure reporting focus of Jagmag, here are the **relevant categories** that should be used instead of the generic Nivaran categories:

### **1. Streetlight Categories**
- **Streetlight Outage** - Light not working, broken bulb, flickering
- **Streetlight Damage** - Broken pole, damaged fixture, vandalism
- **Streetlight Maintenance** - Dirty lens, overgrown vegetation, loose wiring
- **Streetlight Safety** - Exposed wires, dangerous conditions, leaning poles

### **2. Road Infrastructure**
- **Road Surface Damage** - Potholes, cracks, damaged asphalt
- **Road Markings** - Faded lines, missing crosswalks, unclear signs
- **Manhole Covers** - Missing, damaged, or loose covers
- **Road Drainage** - Blocked drains, flooding issues, poor drainage

### **3. Traffic Infrastructure**
- **Traffic Signals** - Broken lights, malfunctioning signals, timing issues
- **Traffic Signs** - Damaged, missing, or unclear signs
- **Speed Bumps** - Damaged, missing, or ineffective speed control
- **Traffic Barriers** - Damaged guardrails, missing barriers

### **4. Electrical Infrastructure**
- **Electrical Boxes** - Damaged, exposed, or vandalized electrical boxes
- **Power Lines** - Hanging wires, damaged poles, electrical hazards
- **Street Electrical** - Exposed wiring, electrical fires, power outages
- **Electrical Safety** - Dangerous electrical conditions

### **5. Water Infrastructure**
- **Water Leaks** - Broken pipes, water main breaks, leaks
- **Sewer Issues** - Blocked drains, sewer backups, pipe damage
- **Water Quality** - Contaminated water, discolored water
- **Water Pressure** - Low pressure, no water supply

### **6. Public Safety**
- **Sidewalk Issues** - Broken sidewalks, trip hazards, accessibility
- **Public Benches** - Damaged, missing, or unsafe seating
- **Public Lighting** - Insufficient lighting, dark areas, safety concerns
- **Emergency Access** - Blocked emergency routes, access issues

### **7. Environmental Issues**
- **Garbage & Waste** - Overflowing bins, illegal dumping, litter
- **Tree Hazards** - Fallen branches, dangerous trees, overgrown vegetation
- **Air Quality** - Pollution sources, dust, smoke
- **Water Pollution** - Contaminated water bodies, pollution sources

### **8. Public Facilities**
- **Bus Stops** - Damaged shelters, missing benches, poor lighting
- **Public Toilets** - Damaged, dirty, or non-functional facilities
- **Playgrounds** - Damaged equipment, safety hazards
- **Public Spaces** - Damaged parks, recreational areas

### **9. Communication Infrastructure**
- **Telephone Poles** - Damaged, leaning, or dangerous poles
- **Internet/Phone** - Damaged cables, service disruptions
- **Public Wi-Fi** - Non-functional hotspots, connectivity issues
- **Emergency Communication** - Damaged emergency phones, communication systems

### **10. Transportation Infrastructure**
- **Bicycle Lanes** - Damaged, blocked, or unsafe bike lanes
- **Pedestrian Crossings** - Damaged, missing, or unsafe crossings
- **Public Transport** - Damaged bus stops, transport facilities
- **Parking Infrastructure** - Damaged parking meters, facilities

---

## 🎯 **Category Implementation**

### **Firebase Collection Structure**
```json
{
  "id": "streetlight_outage",
  "name": "Streetlight Outage",
  "description": "Light not working, broken bulb, flickering",
  "icon": "lightbulb",
  "department": "Electrical Department",
  "priority": 1,
  "isActive": true
}
```

### **AI Prompt Integration**
The AI service should be updated to use these specific categories instead of the generic Nivaran categories.

### **Priority Levels**
- **High Priority**: Safety hazards, major infrastructure failures
- **Medium Priority**: Moderate inconvenience, needs attention soon
- **Low Priority**: Minor issues, can be addressed later

---

## 🚀 **Next Steps**

1. **Update AI Service** to use these Jagmag-specific categories
2. **Create Firebase collection** with these categories
3. **Update UI** to display category-specific icons and colors
4. **Implement category filtering** in the feed
5. **Add category-based notifications** for officials

These categories are specifically tailored for **streetlight and infrastructure reporting** and will provide a much better user experience for Jagmag compared to the generic categories from Nivaran.
