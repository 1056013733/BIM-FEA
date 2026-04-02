import os
import subprocess
import sys
import time

def run_step(title, ps_script):
    print(f"\n{'-'*60}")
    print(f"▶ Ready to execute: {title}")
    print(f"▶ Script path: {ps_script}")
    print(f"{'-'*60}")
    print(f"\n[Starting execution for: {title}]")
    start_time = time.time()
    
    try:
        # Use subprocess to call PowerShell and execute the script, streaming output to console
        subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script],
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"\n[Error] Script execution failed, exit code: {e.returncode}")
    except FileNotFoundError:
        print(f"\n[Error] PowerShell command not found, please check your environment variables.")
        sys.exit(1)
        
    end_time = time.time()
    print(f"\n[Execution completed for: {title}] Total time: {end_time - start_time:.2f} seconds\n")


def main():
    print("="*70)
    print("【ANSYS Simulation Workflow Automation and Recording】".center(64))
    print("="*70)
    
    # Dynamically read the data source declaration from README.md
    print("\n[Data Source & Execution Notes - Read from README.md]")
    try:
        readme_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "README.md")
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()
            if "### Data Source Declaration" in content:
                # Extract and print the declaration part
                declaration = content.split("### Data Source Declaration")[1].strip()
                print(declaration)
            else:
                print("Please check the data source declaration in README.md.")
    except Exception as e:
        print(f"(Failed to read README.md: {e})")
    
    print("="*70)
    
    script_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts")
    
    # Configure the automated execution list based on the workflow
    steps = [
        ("Major Stage 1: Baseline model run", 
         ["run_thom94d3_ansys.ps1"]),
         
        ("Major Stage 2: Mesh sensitivity study", 
         ["generate_thom94d3_mesh_cases.ps1", 
          "run_thom94d3_mesh_cases.ps1", 
          "extract_thom94d3_mesh_summary.ps1"]),
          
        ("Major Stage 3: Material-parameter sensitivity study", 
         ["generate_thom94d3_param_sensitivity.ps1", 
          "run_thom94d3_param_sensitivity.ps1", 
          "extract_thom94d3_param_summary.ps1"]),
          
        ("Major Stage 4: Extract global summary", 
         ["extract_thom94d3_summary.ps1"])
    ]
    
    for stage_title, scripts in steps:
        print(f"\n\n{'='*70}")
        print(f" {stage_title}")
        print(f"{'='*70}")
        
        input(f">>> Upcoming stage: {stage_title}.\n>>> Please ensure your screen recording is ready, then press Enter to continue...")
        
        for script_name in scripts:
            script_path = os.path.join(script_dir, script_name)
            
            if os.path.exists(script_path):
                run_step(script_name, script_path)
            else:
                print(f"[Warning] Script not found: {script_path}, skipping.")
                

if __name__ == "__main__":
    main()
