function WebStorage(){
	this.init();
	this.store;
}
WebStorage.prototype = {
	init: function(){
		if(typeof(Storage) !== "undefined")
			this.store = localStorage;
		else
			console.log("Sorry, no web storage supported :(. ")
	},
	// store|parse_routine are callbacks
	cache: function(k, store_routine, parse_routine){
		if(storage.includes(k)){
			console.log("In storage: ", k);
			parse_routine(JSON.parse(storage.get(k)));
		}
		else{
			console.log("Not in storage: ", k);
			// var v = 
			store_routine();
			// storage.set(k, JSON.stringify(v));
			// return v;
		}
	}, 	
	includes: function(k){
		if(!this.check_valid) return;
		return this.get(k);
	},
	set: function(k, v){
		if(typeof k === "undefined"){
			throw "Attempt to store undefined key";
			return; // don't store undefined
		}

		if(!this.check_valid) return;

		try {
		  this.store.setItem(k, v)
		} catch (e) {
		  if (e.code == DOMException.QUOTA_EXCEEDED_ERR) {
		    this.clear();
		    this.set(l, v);
		  }
		  else{
		  	console.log(e);
		  }
		}
	},
	keys: function(){
		var keys = [];
		for ( var i = 0, len = this.store.length; i < len; ++i ) {
		  keys.push(this.store.key(i));
		}
		return keys;
	},  
	values: function(){
		var values = [];
		for ( var i = 0, len = this.store.length; i < len; ++i ) {
		  values.push(this.get(this.store.key(i)));
		}
		return values;
	},  
	get: function(k){
		if(!this.check_valid) return;
		return this.store.getItem(k)
	}, 
	remove: function(k){
		if(!this.check_valid) return;
		this.store.removeItem(k);
	}, 
	clear: function(k){
		if(!this.check_valid()) return;
		console.log("Clearing sessionStorage.")
		for(var i in this.store)
			this.store.removeItem(i);
	}, 
	check_valid: function(){
		return this.store ? true: false;
	}
}