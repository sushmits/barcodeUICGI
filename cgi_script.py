#!/usr/bin/python
import cgi, cgitb
import json
import subprocess
import sys

print("Content-type:text/html\n\n")
#print("<html><body>\n")
#print("<H1> HI </H1>\n")
#print("</body></html>")

# Create instance of FieldStorage
form = cgi.FieldStorage()
commandToSplit = subprocess.check_output("cut -d, -f 3 ./data/bc_list.csv| sort | uniq -c", shell=True)

commandEachLine = commandToSplit.split("\n") 
trueNamesList = subprocess.check_output("cat trueNames.txt", shell=True)
trueNamesListLines = trueNamesList.split("\n")

# Get data from fields:

json_string = form.getvalue('json_input')

#print ("""<p>"""+json_string+"""</p>""")

#json_string="""{"amar":"96","bioo":"96","bioo6":"48","biooSm":"48","htcra":"0","htcrb":"0","mtcra":"0","mtcrb":"0","neb":"0","next":"0","tru":"0","barcodes":" - "} """
#json_string="""{"neb":"12","barcodes":"CTTGTA,TTAGGC,CTAGTA"}"""
removecurl_json_string=json_string[1:len(json_string)-1]

#print(removecurl_json_string+"----------------")
json_string_split_lines = removecurl_json_string.split('","')
#print(str(json_string_split_lines)+"---split on , -----")
json_output = subprocess.check_output("./barcode_json.pl '"+json_string+"'", shell=True)


json_out_obj = json.loads(json_output)

if 'ERR' not in json_output:
	json_out_obj['html'] = subprocess.check_output("cat "+json_out_obj['html'], shell=True)

json_out_string = json.dumps(json_out_obj)


print("""<!DOCTYPE html>
<html>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="styling.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script src="controller.js"></script>
    <body>
	<div style="width:100%">
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
	</div>
""")
print(""" <div style="float:left;display: inline-block;width:50%;">
         <div class="pick_barcode" style="padding-left:25px;width:75%;height:33px;"  >
            <h3 style="font-family:Verdana;"> Pick barcodes from the following sets: </h3>
        </div>""")

print("""<form action="cgi_script.py" onsubmit="createJson()" method="POST" >
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
                    <tbody id="tbody">  """)
print("""<tr>
        <td> Pre-selected barcodes (as sequences (space/comma separated))</td><td> - </td>""")
print("""<td> <textarea placeholder="give barcode set as , or ' ' separated " rows="5" cols="40" name="Preselectedbarcodes" id="Preselectedbarcodes"></textarea></td> </tr>""")
for i in range(len(commandEachLine)-1):
        eachLineToBeSplit=commandEachLine[i].lstrip()
        eachLine = eachLineToBeSplit.split(" ")
#        print("""<tr>""")
        print("""<tr>""")
        trueName =""
        for j in range(len(trueNamesListLines)):
                name = trueNamesListLines[j].split("\t")
#               print(str(name)+"-------------")
                if eachLine[1]==name[0]:
                        trueName=name[1]
#       print(trueName+"----------")
        print("""<td><a id="barcode_link"""+str(i)+"""" href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term="""+eachLine[1]+"""" >"""+str(trueName)+"""</a></td>""")

#        print("""<td><a id="barcode_link"""+str(i)+"""" href="http://girihlet.com/ravi/web/barcode_diversity/show_bc.pl?term="""+eachLine[1]+"""" >"""+eachLine[1]+"""</a></td>""")
        print("""<td> """+str(eachLine[0])+"""</td>""")
        print("""<td style="width:10px;" >""")
        print("""<div class="slidecontainer" style="width:75%;"> """)
        print("""<input type="range" min="0" max='"""+str(eachLine[0])+"""' step="1" value ="0" class="slider" id="myRange"""+str(i)+"""" onchange="updateTextInput(this.value,'sliderAmount"""+str(i)+"""')">""")
        print("""</div>""")
        print("""<input type="number" min="0" max='"""+str(eachLine[0])+"""' step="1" value="0" name="sliderAmount"""+str(i)+"""" id='sliderAmount"""+str(i)+"""' style="float:right; width:50px;" onchange="update
Slider(this.value, 'myRange"""+str(i)+"""')">""")
        print("""</td>""")
        print("""</tr>""")

print("""
                    </tbody>
                </table>
            </div>

            <div class="button_div" style="padding-left: 25px; ">
                <button type="submit" class="submit_button">Submit</button>
                <button type="reset" class="submit_button" id="ResetButton" onclick="resetAction()" > Reset </button>
            </div>
        </form>
        <br>
        <div style="padding-left: 25px; ">
            <a href="mailto:ravi@girihlet.com"> Send Feedback </a>
        </div>
	</div>
""")


if "ERR" in json_output:
        print("""<div style="float:left;display: inline-block;width:50%;"> 
		<br>
		<br>
		<p style="font-size:20px;font-family:Verdana;color:Red;" >You have given invalid inputs </p><br><br>""")
        print(""" <h2 style="font-family: Verdana; font-size: 20px;color: Navy;float:center;">Your Inputs </h2>""")
        print("""<table class="table table-bordered" ><th>Barcode</th><th>Number</th><tbody>""")
        for i in range(len(json_string_split_lines)):

                each_line_json=json_string_split_lines[i].split(":")
                if each_line_json[1]!='"0' and each_line_json[1]!='""':
                        print("""<tr><td>"""+each_line_json[0][:len(each_line_json[0])-1].replace('"','')+"""</td><td>"""+each_line_json[1][1:len(each_line_json[1])].replace('"','')+"""</td></tr>""")
        print("""</tbody></table>""")
	#print("""<p style="font-size:20px;font-family:Verdana;color:Red;" >"""+str(json_out_obj['ERR'])+"""</p></div>""")
	json_out_obj_split = str(json_out_obj['ERR']).split(',')
	print("""<table class="table table-bordered">
		<tr><th>Input barcodes Invalid </th><th>Bad distances </th></tr>""")
	print("""<tbody>"""+str(json_out_obj_split[-1])+"""</tbody>""")
	print("""</table>""")
	#print( """<p style="font-size:20px;font-family:Verdana;color:Red;" >"""+json_out_obj_split[-1]+"""</p>""")
	print("""</div>""")
	

else:
	print("""<div class="image" style="float:right;display: inline-block;width:50%;">""")
	print(""" <h2 style="font-family: Verdana; font-size: 20px;color: Navy;float:center;">Your Inputs </h2>""")
	print("""<table class="table table-bordered" ><th>Barcode</th><th>Number</th><tbody>""")
	for i in range(len(json_string_split_lines)):
		
		each_line_json=json_string_split_lines[i].split(":")
		if each_line_json[1]!='"0' and each_line_json[1]!='""':
			print("""<tr><td>"""+each_line_json[0][:len(each_line_json[0])-1].replace('"','')+"""</td><td>"""+each_line_json[1][1:len(each_line_json[1])].replace('"','').replace('}','')+"""</td></tr>""")
	print("""</tbody></table><br>""")
	if 'message' in json_out_obj.keys():
		print("""<p style="font-family: Verdana; font-size: 20px;color: Red;">Warning : """+json_out_obj['message'].replace('_',' ')+"""</p>""")
	print("""
            <br>
	    <h2 style="font-family:Verdana;font-size:30px;color:Navy;"> Validated barcode set	</h2>"""+
            json_out_obj['html']+"""
            <br>""")
	print("""<a href="""+json_out_obj['csv']+""" style="float:left; font-size: 20px;"> Download Barcode set  </a>
		<br>
		<br>
            <a href="""+json_out_obj['dist']+""" style="font-size:20px;"> View matrix of pairwise distance between barcodes </a><br>
            <br>
            <br>""")
	print("""
            <h2 style="font-family: Verdana; font-size:30px;color: Navy;">Diversity</h2>
            <img id="img_graph" style="margin:20px;float:left;" src="""+json_out_obj['fig']+""">
            <br>
        </div>""")

print("</body></html>\n")
sys.exit()
