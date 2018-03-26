module GameInitializerHelper
  CITIES_INITIALIZER = {
	New_York: {pop: 20153634},
	Los_Angeles: {pop: 13310447},
	Chicago: {pop: 9512999},
	Dallas: {pop: 7233323},
	Houston: {pop: 6772469.9}, 
	Washington: {pop: 6131977},
	Philadelphia: {pop: 6070500},
	Miami: {pop: 6066387},
	Atlanta: {pop: 5789700}, 
	Boston: {pop: 4794447}, 
	San_Francisco: {pop: 4679166}, 
	Phoenix: {pop: 4661537}, 
	Riverside: {pop: 4527837}, 
	Detroit: {pop: 4297617}, 
	Seattle: {pop: 3798902},
	Minneapolis: {pop: 3551036},
	San_Diego: {pop: 3317749}, 
	Tampa: {pop: 3032171},
	Denver: {pop: 2853077},
	St_Louis: {pop: 2807002}, 
	Baltimore: {pop: 2798886},
	Charlotte: {pop: 2474314},
	Orlando: {pop: 2441257},
	San_Antonio: {pop: 2429609}, 
	Portland: {pop: 2424955}
  }

  REBELS_FORCES = {
  	rebels: {aircrafts: 4550, tanks: 1750}
  }

  US_FORCES = {
  	us_army: {aircrafts: 8450, tanks: 3250}
  }

  US_LAUNCH_SITES = {
  	usa: {
  	  alaska: {operational: true}, hawaii: {operational: true}, iowa: {operational: true}, 
  	  arctic: {operational: true}, guam: {operational: true}, aleoutians: {operational: true}
  	}
  }

  FORCES_INITIALIZER = {
	europe: {aircrafts: 5000, tanks: 1600}, 
	china: {aircrafts: 3000, tanks: 1920}, 
	russia: {aircrafts: 3300, tanks: 2700}
  }
  
  LAUNCH_SITES_INITIALIZER = {
	europe: {
  	  iceland: {operational: true}, guyana: {operational: true}, tahiti: {operational: true}
  	},
	russia: {
  	  mourmansk: {operational: true}, kamchatka: {operational: true}, sakhaline: {operational: true},
	},
	china: {
	  north: {operational: true}, center: {operational: true}, east: {operational: true}, 
	  west: {operational: true}, south:{operational: true}
	}
  } 

  SPIES_INITIALIZER =  {
	europe: {
			  0 => {name:"James Bond", operational: true}, 
			  1 => {name:"Hubert Bonisseur de La Bath", operational: true}
			},
	russia: {
			  0 => {name:"Anatoly Gogol", operational: true}, 
			  1 => {name: "Kseniya Onatopp", operational: true},
			  2 => {name:"Leonid Pushkin", operational: true}
			},
	china: 	{
			  0 => {name:"Wai Lin", operational: true}, 
			  1 => {name:"Wendi Deng Murdoch", operational: true}
			}
  }

end 