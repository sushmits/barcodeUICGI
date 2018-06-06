

function updateTextInput(slideAmount , sliderAmountVar) {
	var sliderInput = document.getElementById(sliderAmountVar);
	sliderInput.value = slideAmount;

}

function updateSlider(slideAmount , sliderAmountVar) {
	var slider = document.getElementById(sliderAmountVar);
	slider.value = slideAmount;

}



function onclickDistanceMatrix()
{
window.open('http://girihlet.com/ravi/web/barcode_diversity/tmp/mat89380.html');

}

function updateImage()
{
	var randomNumber = Math.random();
	var ran = 0;
	if(randomNumber>0.5)
	{
		ran=1;
	}
	else
	{
		ran=0;
	}

		$("#img_graph").attr("src","http://girihlet.com/ravi/web/barcode_diversity/bargraph.cgi?perf=tmp/fig5431.perf");
}

function createJson() {
	
	var myTable = document.getElementById("selectionTable");
	var json_string = "{" ;
	for( i =0; i < myTable.rows.length -2; i++)
	{
		var name1 = document.getElementById("barcode_link"+i).href;
		var split = name1.split("=");
		var value1 = document.getElementById("sliderAmount"+i).value;
		json_string+= '"'+split[1]+'":"'+value1+'",' ;
		
	}
	var preselected = document.getElementById("Preselectedbarcodes").value.trim().replace(','," ");
	preselected=preselected.replace(/\s+/g,',');
	json_string+='"barcodes":'+'"'+preselected+'"}' ;
    document.getElementsByName('json_input')[0].value = json_string;

}


function resetAction()
{
	var resetButton = document.getElementById("ResetButton");
	
	for ( i=0;i<myTable.rows.length -2 ; i++)
	{
		var sliderAmount = document.getElementById("sliderAmount"+i);
		sliderAmount.value = 0 ;
		var myRange = document.getElementById("myRange"+i);
		myRange.value = 0;
	}
}
