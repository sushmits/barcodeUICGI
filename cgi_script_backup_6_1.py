#!/usr/bin/python

import cgi, cgitb
import json
import subprocess


# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
json_string = form.getvalue('json_input')
#json_string = """{"Truseq":"0","Nextera":"0","NEB":"0","Bioo-6mer":"0","Bioo-8mer":"27","HumanTCRa":"0","HumanTCRb":"0","MouseTCRa":"0","MouseTCRb":"0","Amaryllis":"0","barcodes":" - "}"""

json_output = subprocess.check_output("perl barcode_json.pl '"+json_string+"'", shell=True)
#subprocess.check_output("echo "+json_string+">logs.txt", shell=True)


json_out_obj = json.loads(json_output)

json_out_obj['html'] = subprocess.check_output("cat "+json_out_obj['html'], shell=True)

json_out_string = json.dumps(json_out_obj)

print("Content-type:text/html\r\n\r\n")
print("""<!DOCTYPE html>
<html>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="styling.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script src="controller.js"></script>
    <body>

        <div class="icon-bar">
            <a href="http://girihlet.com/ravi/web/barcode_diversity/help.html"> Help </a> 
            <a href="http://girihlet.com/ravi/web/barcode_diversity/doc/Barcode_caddy.pdf"> Write Up </a> 
            <a href="http://girihlet.com/tools.html"> Tools Home </a>
        </div>

        <br>
        <div class="heading" style="padding-left:25px; " >
            <h1 style="font-family:Verdana; "> Barcode Caddy </h1>
        </div>

        <div class="para" style="padding-left:25px; " >
            <p>
                Barcode Caddy selects an optimum set of barcodes for your sample pool. Custom (or pre-selected) barcode sets can also be validated and/or added while generating new sets. 
            </p>
        </div>

        <div class="pick_barcode" style="padding-left:25px;width:35%;height:33px;"  >
            <h3 style="font-family:Verdana;"> Pick barcodes from the following sets: </h3>
        </div>""")

if "ERR" in json_out_string:
	print("<div> An error occured, please try again. </div>")
else:
	print("""<div class="image">
            <h2 style="font-family: Verdana; font-size: 30px;color: Navy;float:right; padding-right: 220px;">Diversity</h2>
            <br>
	    <br>
	    <br>
            <a href="""+json_out_obj['csv']+""" style="float:left; font-size: 20px;"> Barcodes_csv_download   </a>
            <a href="""+json_out_obj['dist']+""" style="padding-left:30px;font-size:20px;"> Distance </a><br>
            <br>
            <br>"""+
            json_out_obj['html']+"""
	    <br>
            <img id="img_graph" style="margin:20px;" src="""+json_out_obj['fig_lnk']+""">
            <br>
        </div>""")

print("""<form action="./cgi_script.py" onsubmit="createJson()" method="GET" >
            <div style="width:30%;">  
            <input type="hidden" name="json_input">         
                <table id="selectionTable" class="table table-bordered" >
                    <thead>
                        <tr>
                            <th> Set Name </th>
                            <th> Number </th>
                            <th> Slide to select the number of sets</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=tru"> Truseq </a></td>
                            <td> 24 </td>
                            <td style="width:10px;">
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="24" step ="1" value="0" class="slider" id="myRange1" onchange="updateTextInput(this.value, 'sliderAmount1')">
                                </div>

                                <input type="number" min="0" max="24" step ="1" value="0" name="sliderAmount1" id="sliderAmount1" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange1')" >
                            </td>
                        </tr>

                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=next"> Nextera </a></td>
                            <td> 12 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;" >
                                    <input type="range" min="0" max="12" step ="1"  value="0" class="slider" id="myRange2" onchange="updateTextInput(this.value, 'sliderAmount2')">
                                </div>
                                <input type="number"  min="0" max="12" step ="1"  value="0" name="sliderAmount2" id="sliderAmount2" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange2')">
                            </td>
                        </tr>
                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=neb"> NEB </a></td>
                            <td> 12 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="12" step ="1"  value="0" class="slider" id="myRange3" onchange="updateTextInput(this.value, 'sliderAmount3')">
                                </div>
                                <input type="number"  min="0" max="12" step ="1"  value="0" name="sliderAmount3" id="sliderAmount3" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange3')">
                            </td>
                        </tr>
                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=bioo6"> Bioo-6mer </a></td>
                            <td> 48 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="48"  step ="1" value="0" class="slider" id="myRange4" onchange="updateTextInput(this.value, 'sliderAmount4')">
                                </div>
                                <input type="number"  min="0" max="48"  step ="1" value="0" name="sliderAmount4" id="sliderAmount4" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange4')">
                            </td>
                        </tr>
                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=bioo"> Bioo-8mer </a></td>
                            <td> 96 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="96"  step ="1" value="0" class="slider" id="myRange5" onchange="updateTextInput(this.value, 'sliderAmount5')">
                                </div>
                                <input type="number"  min="0" max="96"  step ="1" value="0"  name="sliderAmount5" id="sliderAmount5" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange5')">
                            </td>
                        </tr>
			<tr>
			    <td> <a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=biooSm"> BiooSmRNA</td>
		            <td> 48 </td>
			    <td>
				<div class="slidercontainer" style="width: 75%;"> 
				<input type="range" min="0" max="48" step="1" value="0" class="slider" id="myRange11" onchange="updateTextInput(this.value, 'sliderAmount11')">
				</div>
				<input type="number" min="0" max="48" step="1" value="0" name="sliderAmount11" id="sliderAmount11" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange11')">				
			    </td>
			</tr>
                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=htcra"> HumanTCRa </a></td>
                            <td> 15 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="15"  step ="1"  value="0" class="slider" id="myRange6" onchange="updateTextInput(this.value, 'sliderAmount6')">
                                </div>
                                <input type="number" min="0" max="15"  step ="1"  value="0"   name="sliderAmount6" id="sliderAmount6" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange6')">
                            </td>
                        </tr>

                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=htcrb"> HumanTCRb </a></td>
                            <td> 15 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="15"  step ="1"  value="0" class="slider" id="myRange7" onchange="updateTextInput(this.value, 'sliderAmount7')">
                                </div>
                                <input type="number" min="0" max="15"  step ="1"  value="0" name="sliderAmount7"   id="sliderAmount7" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange7')">
                            </td>
                        </tr>

                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=mtcra"> MouseTCRa </a></td>
                            <td> 16 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="16"  step ="1" value="0" class="slider" id="myRange8" onchange="updateTextInput(this.value, 'sliderAmount8')">
                                </div>
                                <input type="number" min="0" max="16"  step ="1" value="0"  name="sliderAmount8"  id="sliderAmount8" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange8')">
                            </td>
                        </tr>

                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=mtcrb"> MouseTCRb </a></td>
                            <td> 16 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="16" step="1" value="0" class="slider" id="myRange9" onchange="updateTextInput(this.value, 'sliderAmount9')">
                                </div>
                                <input type="number"  min="0" max="16" step="1" value="0"  name="sliderAmount9" id="sliderAmount9" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange9')">
                            </td>
                        </tr>

                        <tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=amar"> Amaryllis </a></td>
                            <td> 96 </td>
                            <td>
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="96"  step ="1" value="0" class="slider" id="myRange10" onchange="updateTextInput(this.value, 'sliderAmount10')">
                                </div>
                                <input type="number" min="0" max="96"  step ="1" value="0"  name="sliderAmount10"  id="sliderAmount10" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange10')">
                            </td>
                        </tr>

                        <tr>
                            <td> Pre-selected barcodes 
                                (as sequences (space/comma separated) ) </td>
                            <td> - </td>
                            <td>
                                <textarea rows="5" cols="40" name="Preselectedbarcodes" id="Preselectedbarcodes" > - </textarea>
                            </td>
                        </tr>

                    </tbody>
                </table>
            </div>

            <div class="button_div" style="padding-left: 25px; ">
                <button class="submit_button" onclick="updateImage()">Submit</button>
            </div>
        </form>
        <br>
        <div style="padding-left: 25px; ">
            <a href="mailto:ravi@girihlet.com"> Send Feedback </a>
        </div> 

    </body>
</html> """)
