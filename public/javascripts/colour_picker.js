var ColourPicker = Class.create();
ColourPicker.prototype = {
    colourArray: new Array(),
    element: null,
    trigger: null,
    tableShown: false,
    
    initialize: function(element, trigger) {
        this.colourArray = new Array();
        this.element = $(element);
        this.trigger = $(trigger);
        
        this.trigger.onclick = this.toggleTable.bindAsEventListener(this);
        // Initialise the color array
        this.initColourArray();
        this.buildTable();
        
    },
    initColourArray: function() {
        var colourMap = new Array('00', '33', '66', '99', 'AA', 'CC', 'EE', 'FF');
        for(i = 0; i < colourMap.length; i++) {
            this.colourArray.push(colourMap[i] + colourMap[i] + colourMap[i]);
        }
        
        // Blue
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[0] + colourMap[0] + colourMap[i]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[i] + colourMap[i] + colourMap[7]);
            }
        }
        
        // Green
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[0] + colourMap[i] + colourMap[0]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[i] + colourMap[7] + colourMap[i]);
            }
        }
        
        // Red
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[i] + colourMap[0] + colourMap[0]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[7] + colourMap[i] + colourMap[i]);
            }
        }
        
        // Yellow
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[i] + colourMap[i] + colourMap[0]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[7] + colourMap[7] + colourMap[i]);
            }
        }
        
        // Cyan
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[0] + colourMap[i] + colourMap[i]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[i] + colourMap[7] + colourMap[7]);
            }
        }
        
        // Magenta
        for(i = 1; i < colourMap.length; i++) {
            if(i != 0 && i != 4 && i != 6) {
                this.colourArray.push(colourMap[i] + colourMap[0] + colourMap[i]);
            }
        }
        for(i = 1; i < colourMap.length; i++) {
            if(i != 2 && i != 4 && i != 6 && i != 7) {
                this.colourArray.push(colourMap[7] + colourMap[i] + colourMap[i]);
            }
        }
    },
    buildTable: function() {
        if(!this.tableShown) {
            html = "<table id=\"" + this.trigger.id + "ColourPicker\" style=\"display: none\" class=\"colorPicker\">"
            for(i = 0; i < this.colourArray.length; i++) {
                if(i % 8 == 0) {
                    html += "<tr>";
                }
                html += "<td style=\"background-color: #" + this.colourArray[i] + ";\" title=\"#" + this.colourArray[i] +  "\" onClick=\"$('" + this.element.id + "').value = '#" + this.colourArray[i] + "'; $('" + this.trigger.id + "ColourPicker').style.display = 'none';\">";
                if(i % 8 == 7) {
                    html += "</tr>";
                }
            }
            html += "</table>";
            new Insertion.After(this.trigger, html);
        }
    },
    toggleTable: function(sender) {
        var obj = $(Event.element(sender).id + 'ColourPicker');
        obj.style.display = (obj.style.display == 'block' ? 'none' : 'block');
    }
}