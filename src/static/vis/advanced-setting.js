var knowledgeNodeData;
var knowledgeEdgeData;
var lastSelectedEvent;
var dataKnowledge;

function getUrlVars(){
    var vars = {}; 
    var param = location.search.substring(1).split('&');
    for(var i = 0; i < param.length; i++) {
        var keySearch = param[i].search(/=/);
        var key = '';
        if(keySearch != -1) key = param[i].slice(0, keySearch);
        var val = param[i].slice(param[i].indexOf('=', 0) + 1);
        if(key != '') vars[key] = decodeURI(val);
    } 
    return vars; 
}

(window.onload = function() {
    knowledgeRender();
    document.getElementById('knowledge-ensure-btn').onclick = function(){
	knowledgeSelectionSave();
    };
})();

function knowledgeRender(){
    var domainId = getUrlVars()['domain-id'];
    
    // // create an array with nodes
    $.ajax({
    	url: '/network-node/'+domainId,
    	dataType: 'text',
    	async: false,
    	success: function(data){
    	    knowledgeNodeData = new vis.DataSet(eval(data));
    	}
    });

    // create an array with edges
    $.ajax({
    	url: '/network-edge/'+domainId,
    	dataType: 'text',
    	async: false,
    	success: function(data){
    	    knowledgeEdgeData = new vis.DataSet(eval(data));
    	}
    });

    // create a network
    var container = document.getElementById('knowledge-structure');
    dataKnowledge = {
	nodes: knowledgeNodeData,
	edges: knowledgeEdgeData
    };

    /* Edit の設定用 */
    function reflectEdit(d, callback){
	d.label = $("#node-edit-text-area").val();
	$("#node-edit-text-area").val(null);
        clearPopUp();
	callback(d);
    }

    function clearPopUp() {
	document.getElementById('knolwedge-edit-text-save-btn').onclick = null;
	document.getElementById('editCancelBtn').onclick = null;
        document.getElementById('network-popUp').style.display = 'none';
    }
    
    function cancelEdit(callback) {
        clearPopUp();
        callback(null);
    }

    function editFloatUp(d, callback){
	$("#before-edit-knowledge-label").empty("span");
	$("#before-edit-knowledge-label").append("<span>"+d.label+"</span>");
	document.getElementById('network-popUp').style.display = 'block';
	document.getElementById('editCancelBtn').onclick = cancelEdit.bind(this, callback);
	document.getElementById('knolwedge-edit-text-save-btn').onclick = reflectEdit.bind(this, d, callback);
    }
    
    var options = {
	physics: true,
	interaction:{
	    hover:true,
	    multiselect: true,
	    navigationButtons: true
	},
	manipulation: {
	    enabled: true,
	    editNode: function(d, callback){
		editFloatUp(d, callback);
	    }
	},
	configure: {
	    enabled: false,
	    filter: 'nodes,edges',
	    showButton: true
	},
	edges:{
	    arrows: {
		to: {enabled: true, scaleFactor:1, type:'arrow'},
	    },
	    arrowStrikethrough: true,
	    chosen: true
	}
    };

    var network = new vis.Network(container, dataKnowledge, options);

    network.on("click", function (params) {
	params.event = "[original event]";
	// document.getElementById('eventSpan').innerHTML = '<h2>Click event:</h2>' + JSON.stringify(params, null, 4);
	//console.log('click event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("doubleClick", function (params) {
	params.event = "[original event]";
	
	//console.log(data.nodes._data);
    });
    network.on("oncontext", function (params) {
	params.event = "[original event]";
    });
    network.on("dragStart", function (params) {
	// There's no point in displaying this event on screen, it gets immediately overwritten
	params.event = "[original event]";
	//console.log('dragStart Event:', params);
	//console.log('dragStart event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("dragging", function (params) {
	params.event = "[original event]";
    });
    network.on("dragEnd", function (params) {
	params.event = "[original event]";
	//console.log('dragEnd Event:', params);
	//console.log('dragEnd event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("zoom", function (params) {
    });
    network.on("showPopup", function (params) {
    });
    network.on("hidePopup", function () {
	//console.log('hidePopup Event');
    });
    network.on("select", function (params) {
	//console.log('select Event:', params);
    });
    network.on("selectNode", function (params) {
	lastSelectedEvent = params;
	//console.log('selectNode Event:', params);
    });
    network.on("selectEdge", function (params) {
	//console.log('selectEdge Event:', params);
    });
    network.on("deselectNode", function (params) {
	//console.log('deselectNode Event:', params);
    });
    network.on("deselectEdge", function (params) {
	//console.log('deselectEdge Event:', params);
    });
    network.on("hoverNode", function (params) {
	//console.log('hoverNode Event:', params);
    });
    network.on("hoverEdge", function (params) {
	//console.log('hoverEdge Event:', params);
    });
    network.on("blurNode", function (params) {
	//console.log('blurNode Event:', params);
    });
    network.on("blurEdge", function (params) {
	//console.log('blurEdge Event:', params);
    });
}


function knowledgeSelectionSave(){
    let domainId = getUrlVars()["domain-id"];
        
    /* システム（当該ドメイン）が持っているすべての知識リスト */
    let resultSystemNodeString = new Array();
    Object.keys(dataKnowledge.nodes._data).forEach(function(d){
    	resultSystemNodeString.push("{id:'"+dataKnowledge.nodes._data[d]['id']+"', label:'"+dataKnowledge.nodes._data[d]['label']+"'}");
    });
    resultSystemNodeString = "["+resultSystemNodeString.toString()+"]";

    /* システム（当該ドメイン）知識が持っているエッジのリスト・ユーザはこれを選択するとかないから，システムのやつだけ持ってりゃOK */    
    let resultSystemEdgesString = new Array();
    Object.keys(dataKnowledge.edges._data).forEach(function(d){
	resultSystemEdgesString.push("{from:'"+dataKnowledge.edges._data[d]['from']+"', to:'"+dataKnowledge.edges._data[d]['to']+"'}");
    });
    resultSystemEdgesString = "["+resultSystemEdgesString.toString()+"]";    

    $.ajax({
    	method: "POST",
    	url: '/node-save',
	data: { jsonData : resultSystemNodeString, domainId : domainId },
    	dataType: 'json',
    	async: false,
    	success: function(d){
	    console.log(d);
    	}
    });

    $.ajax({
    	method: "POST",
    	url: '/edge-save',
	data: { jsonData : resultSystemEdgesString, domainId : domainId },
    	dataType: 'json',
    	async: false,
    	success: function(d){
	    console.log(d);
    	}
    });
}
