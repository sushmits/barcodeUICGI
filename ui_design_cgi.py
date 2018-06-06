#!/usr/bin/python
import cgi, cgitb
import subprocess

commandToSplit = subprocess.check_output("cut -d, -f 3 ./data/bc_list.csv| sort | uniq -c", shell=True)

#print(commandToSplit,"\n");

commandEachLine = commandToSplit.split("\n")

trueNamesList = subprocess.check_output("cat trueNames.txt", shell=True)
trueNamesListLines = trueNamesList.split("\n")
print("""Content-type:text/html\r\n\r\n""")

print("""
<!DOCTYPE html>
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
        </div>
""")



print ("""
        <form action="cgi_script.py" onsubmit="createJson()" method="POST" >
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
                    <tbody id="tbody">
                        <!--tr>
                            <td><a href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term=tru"> Truseq </a></td>
                            <td> 24 </td>
                            <td style="width:10px;">
                                <div class="slidecontainer" style="width: 75%;">
                                    <input type="range" min="0" max="24" step ="1" value="0" class="slider" id="myRange1" onchange="updateTextInput(this.value, 'sliderAmount1')">
                                </div>

                                <input type="number" min="0" max="24" step ="1" value="0" name="sliderAmount1" id="sliderAmount1" style="float:right;width:50px;" onchange="updateSlider(this.value, 'myRange1')" >
                            </td>
                        </tr-->
""")

print("""

                        <tr>
                            <td> Pre-selected barcodes
                                (as sequences (space/comma separated) ) </td>
                            <td> - </td>
                            <td>
                                <textarea placeholder="give barcodeset as , or ' ' separated" rows="5" cols="40" name="Preselectedbarcodes" id="Preselectedbarcodes" ></textarea>
                            </td>
                        </tr>
""")
for i in range(len(commandEachLine)-1):
	eachLineToBeSplit=commandEachLine[i].lstrip()
	eachLine = eachLineToBeSplit.split(" ")
	print("""<tr>""")
	trueName =""
	for j in range(len(trueNamesListLines)):
		name = trueNamesListLines[j].split("\t")
#		print(str(name)+"-------------")
		if eachLine[1]==name[0]:
			trueName=name[1]
#	print(trueName+"----------")	
	print("""<td><a id="barcode_link"""+str(i)+"""" href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term="""+eachLine[1]+"""" >"""+str(trueName)+"""</a></td>""")
	print("""<td> """+str(eachLine[0])+"""</td>""")
	print("""<td style="width:10px;" >""")
	print("""<div class="slidecontainer" style="width:75%;"> """)
	print("""<input type="range" min="0" max='"""+str(eachLine[0])+"""' step="1" value ="0" class="slider" id="myRange"""+str(i)+"""" onchange="updateTextInput(this.value,'sliderAmount"""+str(i)+"""')">""")
	print("""</div>""")
	print("""<input type="number" min="0" max='"""+str(eachLine[0])+"""' step="1" value="0" name="sliderAmount"""+str(i)+"""" id='sliderAmount"""+str(i)+"""' style="float:right; width:50px;" onchange="updateSlider(this.value, 'myRange"""+str(i)+"""')">""")
	print("""</td>""")
	print("""</tr>""")


        
print("""            </tbody>
                </table>
            </div>

            <div class="button_div" style="padding-left: 25px; ">
                <button type="submit" class="submit_button" >Submit</button>
		<button  type="reset" class="submit_button" id="ResetButton" onclick="resetAction()"> Reset </button> 
            </div>
        </form>
        <br>
        <div style="padding-left: 25px; ">
            <a href="mailto:ravi@girihlet.com"> Send Feedback </a>
        </div> 

    </body>
</html> 
""")

