import json
import argparse
import re

# Save workflow in localstorage via index.html, so that comfyui loads it by default

def generate_local_storage_script(workflow_path, workflow_name, workflow_index):
    # Read the workflow file
    with open(workflow_path, 'r') as f:
        workflow_data = json.load(f)
    
    # Fix any multiline strings in widgets_values
    for node in workflow_data['nodes']:
        if 'widgets_values' in node:
            for i, value in enumerate(node['widgets_values']):
                if isinstance(value, str):
                    # Replace actual newlines with \n
                    node['widgets_values'][i] = value.replace('\n', '\\n')

    # Create the script content
    script_content = f"""
    <script>
        localStorage.setItem("Comfy.OpenWorkflowsPaths", JSON.stringify(["workflows/{workflow_name}"]))
        localStorage.setItem("Comfy.PreviousWorkflow", "{workflow_name}")
        localStorage.setItem("Comfy.ActiveWorkflowIndex", "{workflow_index}")
        localStorage.setItem("workflow", JSON.stringify({json.dumps(workflow_data)}))
    </script>
    """
    return script_content

def insert_script_to_html(html_path, script_content):
    with open(html_path, 'r') as f:
        html_content = f.read()
    
    # Insert script before </body> tag
    modified_content = re.sub(
        r'</body>',
        f'{script_content}\n  </body>',
        html_content
    )
    
    with open(html_path, 'w') as f:
        f.write(modified_content)

def main():
    parser = argparse.ArgumentParser(description='Insert localStorage script into ComfyUI index.html')
    parser.add_argument('--workflow-path', required=True, help='Path to the workflow JSON file')
    parser.add_argument('--workflow-name', required=True, help='Name of the workflow file (e.g., tutorial.json)')
    parser.add_argument('--workflow-index', default="1", help='Active workflow index')
    parser.add_argument('--html-path', default="",help='Path to index.html')
    
    args = parser.parse_args()
    
    script_content = generate_local_storage_script(
        args.workflow_path,
        args.workflow_name,
        args.workflow_index
    )

    insert_script_to_html(args.html_path, script_content)
    print(f"Successfully updated {args.html_path} with localStorage settings!")

if __name__ == "__main__":
    main()

# python replace_default_graph.py --workflow-path "/workspace/workflow.json" --workflow-name "workflow.json" --workflow-index 1 --html-path "/workspace/ComfyUI/venv/lib/python3.13/site-packages/comfyui_frontend_package/static/index.html"