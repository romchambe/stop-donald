module GameInitializerHelper

  CITIES_INITIALIZER = {
	New_York: {pop: 20153634, lat:40.712775, long:-74.005973},
	Los_Angeles: {pop: 13310447, lat:34.052234, long: -118.243685},
	Chicago: {pop: 9512999, lat:41.878114, long:-87.629798},
	Dallas: {pop: 7233323, lat:32.776664, long:-96.796988},
	Houston: {pop: 6772469.9, lat:29.760427, long:-95.369803}, 
	Washington: {pop: 6131977, lat:38.907192, long:-77.036871},
	Philadelphia: {pop: 6070500, lat:39.952584, long:-75.165222},
	Miami: {pop: 6066387, lat:25.761680, long:-80.191790},
	Atlanta: {pop: 5789700, lat:33.748995, long:-84.387982}, 
	Boston: {pop: 4794447, lat:42.360082, long:-71.058880}, 
	San_Francisco: {pop: 4679166, lat:37.774929, long:-122.419416}, 
	Phoenix: {pop: 4661537, lat:33.448377, long:-112.074037}, 
	Salt_Lake_City: {pop: 4527837, lat:40.760779, long:-111.891047}, 
	Detroit: {pop: 4297617, lat:42.331427, long:-83.045754}, 
	Seattle: {pop: 3798902, lat:47.606209, long:-122.332071},
	Minneapolis: {pop: 3551036, lat:44.977753, long:-93.265011},
	San_Diego: {pop: 3317749, lat: 32.715738, long:-117.161084}, 
	Tampa: {pop: 3032171, lat: 27.950575, long: -82.457178},
	Denver: {pop: 2853077, lat:39.739236, long:-104.990251},
	St_Louis: {pop: 2807002, lat:38.627003, long: -90.199404}, 
	Kansas_City: {pop: 2472602, lat:39.099722, long:-94.578333},
	Charlotte: {pop: 2474314, lat:35.227087, long:-80.843127},
	Pittsburgh: {pop: 2441257, lat: 40.439722, long: -79.976389},
	San_Antonio: {pop: 2429609, lat: 29.424122, long: -98.493628}, 
	Portland: {pop: 2424955, lat:45.523062, long: -122.676482}
  }

  CITIES_TO_BE_CONQUERED = [:Houston, :Dallas, :Atlanta, :Tampa, :Miami, 
  							:San_Antonio, :Kansas_City, :St_Louis, :Charlotte, :Denver, :Chicago,
  							:Phoenix, :Pittsburgh, :Salt_Lake_City, :Washington, :Philadelphia, :San_Diego, 
  							:Minneapolis, :New_York, :Los_Angeles, :Boston, :Detroit, 
  							:San_Francisco, :Portland, :Seattle]

  REBELS_FORCES = {
  	rebels: {aircrafts: 4550, tanks: 1750}
  }

  US_FORCES = {
  	us_army: {aircrafts: 8450, tanks: 3250}
  }

  US_LAUNCH_SITES = {
  	usa: {
  	  alaska: {operational: true, id: 25, lat:60.430189, long:-151.274455}, hawaii: {operational: true, id: 26, lat: 21.148912, long: -157.040037}, montana: {operational: true, id: 27, lat:47.354236, long:-108.841338}, 
  	  dakota: {operational: true, id: 28, lat:43.304682, long: -97.825234}, porto_rico: {operational: true, id: 29, lat: 18.191921, long: -66.342869}, aleoutians: {operational: true, id: 30, lat:52.979779, long: -168.858138}
  	}
  }

  FORCES_INITIALIZER = {
	europe: {aircrafts: 5000, tanks: 1600}, 
	china: {aircrafts: 3000, tanks: 1920}, 
	russia: {aircrafts: 3300, tanks: 2700}
  }
  
  LAUNCH_SITES_INITIALIZER = {
	europe: {
  	  iceland: {operational: true}, tahiti: {operational: true}, cayenne: {operational: true}
  	},
	russia: {
  	  mourmansk: {operational: true}, kamchatka: {operational: true}, kouriles: {operational: true}
	},
	china: {
	  north: {operational: true}, east: {operational: true}, 
	  west: {operational: true}, south:{operational: true}, center: {operational: true}
	}
  } 

  SPIES_INITIALIZER = {
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
			  1 => {name:"Wendi Deng", operational: true}
			}
  }

  UNITS_POWER = {aircrafts: 3, tanks: 2}

end 