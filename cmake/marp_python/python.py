import generate 
import subprocess 

def inline_file(filename):
    print(open(filename, "r").read(), end = '')
    return

def run_command(command):
    output = subprocess.check_output(command, shell=True) 
    output = output.decode("utf-8")
    print(output, end = '')
    return

def run_silent(command):
    subprocess.check_output(command, shell=True) 
    return

def on_python(python_code):
    one_liner = python_code.count("\n") < 2
    if one_liner:
        python_code = python_code.strip()
    exec (python_code) in {'__builtins__':{}}, {}
    return

generate.match_and_expand("python", on_python)
