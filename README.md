# Flow Chatmode for GitHub Copilot

Specialized GitHub Copilot's chatmode for creating and evaluating sophisticated decision flow graphs using Gherkin DSL with Decision Graph Notation conventions for complex workflow automation.

## Overview

The Flow chatmode transforms GitHub Copilot into an expert Systems Architect and Process Designer, capable of generating comprehensive decision graphs that model complex business workflows. It supports dual output formats: familiar Gherkin DSL `.feature` files and structured YAML Decision Graph Notation (`.dgn.yaml`) files - providing powerful approaches for modeling conditional logic, state transitions, and MCP tool orchestration.

## Key Features

### 🎯 **Decision Graph Generation**
- **Dual Output Formats**: Generate both Gherkin `.feature` files and structured YAML `.dgn.yaml` decision graphs
- **Three Node Types**: Decision nodes (conditional logic), End nodes (terminal states), Chance nodes (probabilistic selection)
- **State-Driven Architecture**: Complete state object management throughout workflow execution
- **Conditional Logic**: Examples tables and YAML decision tables with probability-based routing
- **MCP Tool Integration**: Seamless integration with Model Context Protocol tools for external system interaction
- **Organized File Structure**: Automatic storage in `features/flows/` with appropriate file extensions

### 🔍 **Decision Graph Evaluation**
- **Interactive Testing**: Execute decision graphs with specified inputs to see complete traversal paths
- **Dual Format Support**: Evaluate both `.feature` and `.dgn.yaml` decision graphs
- **State Transition Tracking**: Detailed reporting of state changes at each node
- **Visual Path Representation**: ASCII diagrams showing execution flow and decision points
- **Alternative Path Analysis**: Identify other possible execution routes and decision outcomes
- **Comprehensive Test Reports**: Generate `.feature.tests.md` and `.dgn.tests.md` evaluation reports

### ⚡ **Production-Ready Output**
- **Mandatory Validation**: 3-iteration improvement cycle ensures production readiness
- **Comprehensive Testing**: Built-in test case generation and validation
- **Error Handling**: Complete error recovery and edge case coverage
- **Performance Optimization**: Efficient tool selection and parallel execution capabilities

## Installation

### 1. Add Flow Chatmode to VS Code

Place the Flow chatmode definition in your VS Code workspace:

```
.github/
└── chatmodes/
    └── Flow.chatmode.md
```

### 2. Enable in VS Code Settings

Add to your VS Code settings or workspace configuration:

```json
{
  "github.copilot.chat.modes": [
    ".github/chatmodes/Flow.chatmode.md"
  ]
}
```

### 3. Restart VS Code

After adding the chatmode file, restart VS Code to load the new chatmode.

## Getting Started

### Basic Usage

1. **Open Copilot Chat** in VS Code
2. **Select Flow Mode** from the chatmode dropdown
3. **Request a Flow**: Describe your workflow requirements

```
Create a user authentication flow with password reset and account lockout
```

### Advanced Usage

**Generate with Specific Requirements:**
```
Create an e-commerce order processing flow with inventory validation, 
payment processing, fraud detection, and shipping coordination
```

**Request Specific Output Format:**
```
Generate a user authentication flow in YAML format with account lockout 
and password reset capabilities
```

**Evaluate Existing Flows:**
```
Evaluate the user-auth-flow for input: 
username='john.doe', 
password_attempts=3, 
account_status='active', 
last_login='2025-10-15'
```

## Decision Graph Notation

The Flow chatmode supports two powerful formats for modeling decision graphs:

### 1. Gherkin DSL Format (`.feature` files)

Uses Gherkin DSL with specialized conventions to create Decision Graph Notation:

#### **Examples Tables as Decision Tables**
```gherkin
Examples: Decision table name
  | input:state.property | output:state.property | mcp_tool:name | probability | transition |
  | user_input_value    | calculated_output     | semantic_search | 0.8 | next-scenario |
```

#### **Node Type Annotations**
```gherkin
@flow:decision_node     # Conditional logic with deterministic routing
@flow:end_node          # Terminal states (empty transition column)
@flow:chance_node       # Probabilistic selection when multiple rows match
```

#### **State Object Management**
```gherkin
@scenario_id:unique-identifier
Scenario Outline: Process State Transition
  Given current state contains <input:state.property>
  When condition <input:state.criteria> is evaluated
  Then execute tool <mcp_tool:name>
  And update state to <output:state.result>
  And transition to <transition>
```

### 2. YAML Decision Graph Notation (`.dgn.yaml` files)

Structured YAML format for complex decision graphs:

```yaml
metadata:
  name: "Business Process Decision Flow"
  description: "Automated decision logic for business process"
  version: "1.0"
  created: "2025-11-02"
  type: "decision_graph_notation"

context:
  background:
    description: "Business Process Context"
    prerequisites:
      - workflow_engine_initialized: true
      - mcp_tool_registry_available: true
      - required_tools_configured: true

nodes:
  - node:
      id: "process-intake"
      type: "decision_node"
      context: ["validation", "processing"]
      description: "Process Initial Request"
      scenario:
        Given:
          - a new request with type <input__state.request_type>
          - request priority is <input__state.priority>
        When:
          - the system validates the request
        Then:
          - it should execute tool <mcp_tool__name>
          - set validation status to <output__state.validation_status>
          - transition to <transition>
      decision_table:
        name: "Request processing decision table"
        columns:
          - "input__state.request_type"
          - "input__state.priority"
          - "mcp_tool__name"
          - "mcp_tool__output_sample"
          - "output__state.validation_status"
          - "probability"
          - "transition"
        rows:
          - "input:state.request_type": "urgent"
            "input:state.priority": "high"
            "mcp_tool:name": "semantic_search"
            "mcp_tool:output_sample": '{"validation": "approved", "priority": "immediate"}'
            "output:state.validation_status": "approved"
            "probability": 1.0
            "transition": "priority-processing"

workflow_execution:
  start_node: "process-intake"
  state_management:
    initial_state: {}
    state_transitions: true
    state_persistence: true
```

### File Organization Structure

```
features/flows/
├── process-name.feature              # Gherkin DSL decision graph
├── process-name.dgn.yaml            # YAML decision graph
├── process-name.feature.tests.md    # Gherkin evaluation report
└── process-name.dgn.tests.md        # YAML evaluation report
```

### Decision Table Columns (Both Formats)

| Column Type | Gherkin Format | YAML Format | Purpose |
|------------|---------|-------------|---------|
| **Input State** | `<input:state.property_name>` | `input__state.property_name` | Drive decision logic |
| **Output State** | `<output:state.property_name>` | `output__state.property_name` | Update workflow state |
| **MCP Tool** | `<mcp_tool:name>` | `mcp_tool__name` | Tool to execute for this path |
| **Mock Output** | `<mcp_tool:output_sample>` | `mcp_tool__output_sample` | Sample output for testing |
| **Probability** | `<probability>` | `probability` | Selection weight (0.0-1.0) |
| **Transition** | `<transition>` | `transition` | Next scenario ID (empty for End nodes) |

## Flow Chatmode Capabilities

### 1. **Automatic Flow Generation**
- **Dual Format Output**: Generate both Gherkin `.feature` and YAML `.dgn.yaml` formats
- **Business Logic Analysis**: Converts requirements into decision trees
- **State Management**: Comprehensive state object design
- **Tool Selection**: Optimal MCP tool assignment based on requirements
- **Error Handling**: Complete error recovery path generation
- **Organized Storage**: Automatic file organization in `features/flows/` directory

### 2. **Mandatory Validation Protocol**
Every generated flow undergoes a rigorous 3-iteration improvement cycle:

1. **Initial Generation**: Create requested flow based on requirements
2. **First Enhancement**: Review for completeness and optimization
3. **Second Enhancement**: Analyze for edge cases and performance
4. **Final Validation**: Comprehensive production readiness review

### 3. **Comprehensive Testing**
- **Scenario Coverage**: Test every Examples table row
- **Edge Case Validation**: Boundary conditions and error scenarios
- **Integration Testing**: MCP tool compatibility verification
- **Performance Analysis**: Execution time and resource usage assessment

### 4. **Decision Graph Evaluation**
When evaluating flows with specified inputs:

- **Multi-Format Support**: Evaluate both `.feature` and `.dgn.yaml` decision graphs
- **State Object Creation**: Initialize properties to identify start node
- **Step-by-Step Execution**: Detailed node-by-node traversal
- **Decision Logic Explanation**: Why specific table rows were selected
- **Visual Path Representation**: ASCII diagrams of execution flow
- **Alternative Path Analysis**: Other possible execution routes
- **Test Report Generation**: Create comprehensive `.tests.md` evaluation reports

## Example: Health Insurance Claim Processing

### Generated Flow Structure (Gherkin Format)
```gherkin
Feature: Health Insurance Claim Processing Decision Flow
  As a health insurance system
  I want to process claims through automated decision logic
  So that claims are efficiently evaluated and processed

@flow:decision_node
@scenario_id:claim-intake
Scenario Outline: Process Initial Claim Intake
  Given a new claim is submitted with claim type <input:state.claim_type>
  And claim amount is <input:state.claim_amount>
  When the intake system validates the claim
  Then it should execute tool <mcp_tool:name>
  And transition to <transition>

  Examples: Claim intake decision table
    | input:state.claim_type | input:state.claim_amount | mcp_tool:name | probability | transition |
    | emergency | state.claim_amount > 10000 | semantic_search | 1.0 | priority-review |
    | routine | state.claim_amount <= 5000 | file_search | 0.9 | eligibility-check |
    | preventive | state.claim_amount <= 1000 | create_file | 1.0 | auto-approval |
```

### Generated Flow Structure (YAML Format)
```yaml
metadata:
  name: "Health Insurance Claim Processing Decision Flow"
  description: "Automated decision logic for health insurance claim processing"
  version: "1.0"
  type: "decision_graph_notation"

nodes:
  - node:
      id: "claim-intake"
      type: "decision_node"
      context: ["claim_validation", "initial_processing"]
      description: "Process Initial Claim Intake"
      decision_table:
        name: "Claim intake decision table"
        columns:
          - "input__state.claim_type"
          - "input__state.claim_amount"
          - "mcp_tool__name"
          - "probability"
          - "transition"
        rows:
          - "input:state.claim_type": "emergency"
            "input:state.claim_amount": "state.claim_amount > 10000"
            "mcp_tool:name": "semantic_search"
            "probability": 1.0
            "transition": "priority-review"

workflow_execution:
  start_node: "claim-intake"
  state_management:
    initial_state: {}
    state_transitions: true
```

### Test Case Example
```
Evaluate the health-insurance-claim-flow for input: 
claim_type='emergency', 
claim_amount=15000, 
policy_status='active', 
member_tier='premium'
```

### File Structure Generated
```
features/flows/
├── health-insurance-claim-flow.feature          # Gherkin DSL version
├── health-insurance-claim-flow.dgn.yaml        # YAML version
├── health-insurance-claim-flow.feature.tests.md # Gherkin evaluation report
└── health-insurance-claim-flow.dgn.tests.md    # YAML evaluation report
```

### Expected Evaluation Output
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│ @claim-intake       │───▶│ @priority-review    │───▶│ @payment-approval   │
│ (Decision)          │    │ (Decision)          │    │ (End)               │
│ p=1.0, row=1        │    │ p=1.0, row=1        │    │ Terminal Node       │
│ semantic_search     │    │ semantic_search     │    │ create_file         │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘

Execution Summary:
- Total Steps: 3 nodes traversed
- Tools Used: semantic_search (2x), create_file (1x)
- Final Status: Emergency claim approved and paid
- Processing Time: ~2 minutes (emergency fast-track)
```

## Advanced Features

### Expression Language Support
Decision table cells support multiple expression types:

**JavaScript Expressions:**
```gherkin
| state.claim_amount * 0.8 | state.retry_count + 1 | "high" if complexity > 5 else "medium" |
```

**Natural Language Logic:**
```gherkin
| "approved" if medical_necessity and in_network else "review_required" |
```

**Mathematical Formulas:**
```gherkin
| Math.min(state.benefit_limit, state.claim_amount * coverage_percentage) |
```

### Probabilistic Decision Making
Chance nodes enable sophisticated routing logic:

```gherkin
@flow:chance_node
@scenario_id:load-balancer
Examples: Server routing with probabilities
  | input:state.server_load | server_choice | probability | transition |
  | state.load < 50 | primary_server | 0.8 | process-request |
  | state.load >= 50 | backup_server | 0.6 | process-request |
  | state.load > 90 | queue_request | 0.2 | request-queue |
```

### Parallel Execution Patterns
Model concurrent processing workflows:

```gherkin
@flow:parallel_execution
@scenario_id:concurrent-validation
Examples: Parallel validation processes
  | validation_type | mcp_tool:name | sync_mode | transition |
  | security_check | semantic_search | async | security-results |
  | compliance_check | file_search | async | compliance-results |
  | business_rules | create_file | sync | rule-validation |
```

## Best Practices

### 1. **Flow Design**
- **Choose Format**: Select Gherkin `.feature` or YAML `.dgn.yaml` based on complexity and team preferences
- **Start Simple**: Begin with core happy path, then add edge cases
- **State-First**: Design your state object properties before building decision tables
- **Clear Naming**: Use descriptive scenario IDs and meaningful state property names
- **Error Handling**: Always include error recovery paths and terminal denial states
- **File Organization**: Use consistent naming conventions for related flow files

### 2. **Decision Tables**
- **Comprehensive Coverage**: Ensure all possible input combinations are handled
- **Probability Values**: Use meaningful probabilities for chance nodes (sum doesn't need to equal 1.0)
- **Expression Usage**: Leverage expressions for complex business logic
- **Tool Selection**: Choose appropriate MCP tools for each decision path

### 3. **Testing Strategy**
- **Format-Specific Testing**: Test both Gherkin and YAML versions if using dual formats
- **Boundary Testing**: Test edge cases and threshold values
- **Error Scenarios**: Validate error handling and recovery paths
- **Performance Testing**: Verify execution times meet requirements
- **Integration Testing**: Confirm MCP tool compatibility
- **Test Report Review**: Analyze generated `.tests.md` files for completeness

### 4. **Production Deployment**
- **Validation Completion**: Ensure 3-iteration cycle is completed
- **Documentation**: Maintain clear flow documentation and test cases
- **Monitoring**: Implement execution tracking and performance monitoring
- **Versioning**: Use proper version control for flow updates

## Common Use Cases

### Business Process Automation
- **Approval Workflows**: Multi-level approval processes with conditional routing
- **Customer Onboarding**: Identity verification, document processing, account setup
- **Order Processing**: Inventory, payment, fulfillment, and shipping coordination
- **Support Ticket Routing**: Priority-based assignment with escalation paths

### System Integration
- **API Orchestration**: Sequential and parallel API call coordination
- **Data Pipeline Management**: ETL processes with error handling and retry logic
- **Microservice Coordination**: Service mesh communication patterns
- **Event-Driven Architecture**: Event processing and reaction workflows

### Decision Support Systems
- **Risk Assessment**: Credit scoring, fraud detection, compliance checking
- **Resource Allocation**: Load balancing, capacity planning, optimization
- **Content Management**: Publishing workflows, review processes, archival
- **Quality Assurance**: Testing pipelines, validation processes, certification

## Troubleshooting

### Common Issues

**Flow Not Loading:**
- Verify `.github/chatmodes/Flow.chatmode.md` file exists
- Check VS Code settings include the chatmode path
- Restart VS Code after adding the chatmode

**Evaluation Errors:**
- Ensure all required input properties are provided
- Verify state property names match decision table columns (check both formats)
- Check that scenario IDs in transitions exist in the flow
- Validate file extensions match evaluation format (.feature vs .dgn.yaml)

**Poor Performance:**
- Review decision table complexity
- Optimize MCP tool selection
- Consider parallel execution opportunities
- Validate state object size and complexity

### Getting Help

**Flow Generation Issues:**
- Provide detailed requirements and constraints
- Specify preferred output format (Gherkin, YAML, or both)
- Specify input/output data structures
- Include business rules and edge cases
- Request specific testing scenarios

**Evaluation Problems:**
- Share complete input parameters
- Include expected vs actual behavior
- Provide flow file context
- Specify evaluation environment details

## Contributing

### Extending the Chatmode
- **New Node Types**: Add specialized node patterns for specific domains
- **Format Enhancements**: Improve Gherkin and YAML format capabilities
- **Tool Integration**: Expand MCP tool library and usage patterns
- **Expression Languages**: Add support for additional expression types
- **Visualization**: Enhance path visualization and reporting formats

### Best Practice Sharing
- **Flow Patterns**: Share reusable flow templates for common scenarios
- **Testing Strategies**: Contribute effective testing approaches and tools
- **Performance Optimization**: Share optimization techniques and benchmarks
- **Integration Examples**: Provide real-world integration scenarios and solutions

## License

This chatmode is designed for use with GitHub Copilot in VS Code. Ensure compliance with GitHub Copilot terms of service and your organization's AI usage policies.

---

**Flow Chatmode Version**: 1.1  
**Compatible with**: VS Code + GitHub Copilot  
**Last Updated**: November 2, 2025  

For more examples and advanced usage patterns, see the complete Flow chatmode definition and health insurance claim processing example (both Gherkin `.feature` and YAML `.dgn.yaml` formats) included in this repository.
