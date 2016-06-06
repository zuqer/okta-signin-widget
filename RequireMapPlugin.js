/*
var path = require('path');

function RequireMapPlugin(map, options) {

	// Convert the map into absolute mappings using aliases

	var basePath = options.basePath;

	this.apply = function(compiler) {
		var parentModule;
		var isInBasePath = false;

		compiler.plugin('normal-module-factory', function(nmf) {
		  nmf.plugin('before-resolve', function(data, cb) {
		  	var childModule = data.request;

		  	if (childModule[0] === '.' && isInBasePath) {
		  		var resolvedRequest = path.resolve(data.context, data.request);
		  		var relativePath = path.relative(basePath.path, resolvedRequest);
	    		if (relativePath[0] !== '.') {
	    			childModule = path.join(basePath.alias || '', relativePath);
	    		}
		  	}

		  	console.log('currentIssuer', parentModule, 'requestedModule', childModule);

		  	if (map[parentModule] && map[parentModule][childModule]) {
		  		data.request = map[parentModule][childModule];

		  	} else if (map['*'] && map['*'][childModule]) {
		  		data.request = map['*'][childModule];
		  	}

		    cb(null, data);
		  });
		});

		compiler.plugin('compilation', function(c) {
	    c.plugin('succeed-module', function(module) {
	    	var relativePath = path.relative(basePath.path || compiler.context, module.request);
	    	if (relativePath[0] === '.') {
	    		isInBasePath = false;
	    	} else {
	    		isInBasePath = true;
	    	}

	    	// If it's not a relative path
	    	if (!isInBasePath || module.rawRequest[0] !== '.') {
	    		parentModule = module.rawRequest;

	    	} else {
    			// Remove the file extension
    			var modulePath = relativePath.slice(0, -path.extname(relativePath).length);
    			parentModule = path.join(basePath.alias || '', modulePath);
	    	}
	    });
	  });
	};
}
/*/
function RequireMapPlugin(map) {
	this.apply = function(compiler) {
		var parentModule;
		compiler.plugin('normal-module-factory', function(nmf) {
		  nmf.plugin('before-resolve', function(data, cb) {
		  	var childModule = data.request;

		  	//console.log('currentIssuer', parentModule, 'requestedModule', childModule);
		  	if (map[parentModule] && map[parentModule][childModule]) {
		  		data.request = map[parentModule][childModule];

		  	} else if (map['*'] && map['*'][childModule]) {
		  		data.request = map['*'][childModule];
		  	}

		    cb(null, data);
		  });
		});

		compiler.plugin('compilation', function(c) {
	    c.plugin('succeed-module', function(module) {
	    	parentModule = module.rawRequest;
	    	if (parentModule === './helpers/InputFactory') {
	    		//console.log(module);
	    	}
	    });
	  });
	};
}
//*/

module.exports = RequireMapPlugin;