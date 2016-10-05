/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports) {

	;__weex_define__("@weex-component/602948194f230b42df87136aa6901886", [], function(__weex_require__, __weex_exports__, __weex_module__){

	;
	  __weex_module__.exports = {
	    data: function () {return {
	      ctHeight: 800,
	      img: 'http://gw.alicdn.com/tps/i2/TB1DpsmMpXXXXabaXXX20ySQVXX-512-512.png_400x400.jpg'
	    }},

	    methods: {
	      showInfo : function(e) {
	        console.log(e);
	        //alert('点击事件');
	        var router = __weex_require__('@weex-module/router');
	        router.pushToVC('id',{},function(ret){
	          console.log(ret);
	        });
	      }
	    },

	    ready: function () {
	      this.ctHeight = this.$getConfig().env.deviceHeight
	    }
	  }

	;__weex_module__.exports.template = __weex_module__.exports.template || {}
	;Object.assign(__weex_module__.exports.template, {
	  "type": "div",
	  "classList": [
	    "ct"
	  ],
	  "style": {
	    "height": function () {return this.ctHeight}
	  },
	  "children": [
	    {
	      "type": "image",
	      "classList": [
	        "img"
	      ],
	      "style": {
	        "width": 300,
	        "height": 300
	      },
	      "attr": {
	        "src": function () {return this.img}
	      }
	    },
	    {
	      "type": "text",
	      "style": {
	        "fontSize": 42
	      },
	      "attr": {
	        "value": "Hello Weex xxx!"
	      }
	    },
	    {
	      "type": "text",
	      "style": {
	        "fontSize": 30
	      },
	      "events": {
	        "click": "showInfo"
	      },
	      "attr": {
	        "value": "点击"
	      }
	    }
	  ]
	})
	;__weex_module__.exports.style = __weex_module__.exports.style || {}
	;Object.assign(__weex_module__.exports.style, {
	  "ct": {
	    "alignItems": "center",
	    "justifyContent": "center"
	  },
	  "img": {
	    "marginBottom": 20
	  }
	})
	})
	;__weex_bootstrap__("@weex-component/602948194f230b42df87136aa6901886", {
	  "transformerVersion": "0.3.1"
	},undefined)

/***/ }
/******/ ]);