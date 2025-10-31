Feature: Health Insurance Claim Processing Decision Flow
  As a health insurance system
  I want to process claims through automated decision logic
  So that claims are efficiently evaluated and processed

@flow:context
Background: Health Insurance Claim Processing Context
  Given the workflow engine is initialized
  And the MCP tool registry is available
  And the claim processing context is empty
  And all required tools are configured
  And insurance policy database is accessible
  And medical provider network is available
  And fraud detection system is enabled
  And member eligibility database is current
  And payment processing system is operational

@flow:decision_node
@scenario_id:claim-intake
@context:claim_validation,initial_processing
Scenario Outline: Process Initial Claim Intake
  Given a new claim is submitted with claim type <input:state.claim_type>
  And claim amount is <input:state.claim_amount>
  And policy status is <input:state.policy_status>
  And member tier is <input:state.member_tier>
  When the intake system validates the claim
  Then it should execute tool <mcp_tool:name>
  And set validation status to <output:state.validation_status>
  And update processing priority to <output:state.processing_priority>
  And record intake timestamp as <output:state.intake_timestamp>
  And transition to <transition>

  Examples: Claim intake decision table
    | input:state.claim_type | input:state.claim_amount | input:state.policy_status | input:state.member_tier | mcp_tool:name | mcp_tool:output_sample | output:state.validation_status | output:state.processing_priority | output:state.intake_timestamp | probability | transition |
    | emergency | state.claim_amount > 10000 | active | premium | semantic_search | {"validation": "priority_review", "flags": ["high_amount"], "estimated_time": "2hrs"} | "requires_priority_review" | "high" | new Date().toISOString() | 1.0 | priority-review |
    | routine | state.claim_amount <= 5000 | active | standard | file_search | {"validation": "auto_eligible", "checks_passed": 5, "processing_time": "15min"} | "auto_approved_eligible" | "standard" | timestamp_now | 0.9 | eligibility-check |
    | routine | state.claim_amount > 5000 AND state.claim_amount <= 10000 | active | standard | semantic_search | {"validation": "requires_review", "amount_threshold": "exceeded", "manual_check": true} | "requires_amount_review" | "medium" | timestamp_now | 0.8 | manual-review |
    | preventive | state.claim_amount <= 1000 | active | state.member_tier | create_file | {"validation": "fast_track", "preventive_benefit": true, "coverage": 100} | "preventive_approved" | "low" | current_timestamp | 1.0 | auto-approval |
    | specialist | state.claim_amount > 2000 | active | premium | grep_search | {"validation": "manual_review", "specialist_network": true, "prior_auth": "required"} | "requires_manual_review" | "medium" | format_timestamp(now) | 0.8 | manual-review |
    | any | state.claim_amount | inactive | state.member_tier | run_in_terminal | {"validation": "policy_inactive", "error": "coverage_expired", "action": "deny"} | "policy_inactive" | "immediate" | error_timestamp | 1.0 | claim-denied |
    | any | state.claim_amount > 50000 | active | state.member_tier | semantic_search | {"validation": "fraud_check_required", "high_amount_flag": true, "investigation": "required"} | "fraud_investigation_required" | "urgent" | fraud_timestamp | 1.0 | fraud-investigation |

@flow:decision_node
@scenario_id:fraud-investigation
@context:fraud_detection,security_validation
Scenario Outline: Investigate Potential Fraudulent Claims
  Given claim amount exceeds fraud threshold <input:state.fraud_threshold>
  And claim pattern analysis shows <input:state.pattern_analysis>
  And provider history indicates <input:state.provider_history>
  And member claim history shows <input:state.member_history>
  When the fraud detection system analyzes the claim
  Then it should execute tool <mcp_tool:name>
  And set fraud risk score to <output:state.fraud_risk_score>
  And update investigation status to <output:state.investigation_status>
  And set security flag to <output:state.security_flag>
  And transition to <transition>

  Examples: Fraud investigation decision table
    | input:state.fraud_threshold | input:state.pattern_analysis | input:state.provider_history | input:state.member_history | mcp_tool:name | mcp_tool:output_sample | output:state.fraud_risk_score | output:state.investigation_status | output:state.security_flag | probability | transition |
    | state.claim_amount > 50000 | suspicious_pattern | clean_history | normal_usage | semantic_search | {"fraud_score": 0.3, "investigation": "standard_review", "provider_verified": true} | 0.3 | "standard_investigation" | "low_risk" | 0.7 | manual-review |
    | state.claim_amount > 100000 | multiple_red_flags | suspicious_activity | excessive_claims | grep_search | {"fraud_score": 0.8, "investigation": "full_investigation", "hold_payment": true} | 0.8 | "full_fraud_investigation" | "high_risk" | 0.9 | fraud-hold |
    | state.claim_amount > 25000 | normal_pattern | verified_provider | first_time_claim | file_search | {"fraud_score": 0.1, "investigation": "expedited_review", "clear_to_process": true} | 0.1 | "expedited_clearance" | "clear" | 0.8 | eligibility-check |

@flow:end_node
@scenario_id:fraud-hold
@context:fraud_prevention,claim_suspension
Scenario Outline: Process Fraud Hold on Claims
  Given fraud investigation requires claim suspension
  And fraud risk score is <input:state.fraud_risk_score>
  And investigation type is <input:state.investigation_type>
  When the fraud system places hold on claim
  Then it should execute tool <mcp_tool:name>
  And set hold status to <output:state.hold_status>
  And record investigation reference as <output:state.investigation_reference>
  And set estimated resolution time to <output:state.resolution_time>
  And update member notification to <output:state.member_notification>

  Examples: Fraud hold completion table
    | input:state.fraud_risk_score | input:state.investigation_type | mcp_tool:name | mcp_tool:output_sample | output:state.hold_status | output:state.investigation_reference | output:state.resolution_time | output:state.member_notification | probability | transition |
    | state.fraud_risk_score > 0.7 | full_investigation | create_file | {"hold_placed": true, "ref": "FRAUD-2025-001", "investigation_time": "30_days"} | "fraud_hold_active" | "FRAUD-INV-" + generate_case_id() | "30 business days" | "investigation_notice_sent" | 1.0 | |
    | state.fraud_risk_score > 0.5 | standard_investigation | semantic_search | {"hold_placed": true, "ref": "REVIEW-2025-001", "investigation_time": "15_days"} | "review_hold_active" | "REVIEW-" + generate_case_id() | "15 business days" | "review_notice_sent" | 0.9 | |

@flow:decision_node
@scenario_id:eligibility-check
@context:policy_verification,coverage_validation
Scenario Outline: Verify Member Eligibility and Coverage
  Given claim validation status is <input:state.validation_status>
  And member ID is <input:state.member_id>
  And service date is <input:state.service_date>
  And provider network status is <input:state.provider_network>
  When the eligibility system validates coverage
  Then it should execute tool <mcp_tool:name>
  And set eligibility result to <output:state.eligibility_result>
  And update coverage percentage to <output:state.coverage_percentage>
  And set deductible status to <output:state.deductible_status>
  And transition to <transition>

  Examples: Eligibility verification decision table
    | input:state.validation_status | input:state.member_id | input:state.service_date | input:state.provider_network | mcp_tool:name | mcp_tool:output_sample | output:state.eligibility_result | output:state.coverage_percentage | output:state.deductible_status | probability | transition |
    | auto_approved_eligible | state.member_id | within_policy_period | in_network | semantic_search | {"eligible": true, "coverage": 80, "deductible_met": false, "copay": 25} | "eligible_in_network" | 80 | "deductible_not_met" | 1.0 | payment-calculation |
    | auto_approved_eligible | state.member_id | within_policy_period | out_of_network | file_search | {"eligible": true, "coverage": 60, "deductible_met": false, "penalty": "out_network"} | "eligible_out_network" | 60 | "deductible_not_met" | 1.0 | payment-calculation |
    | auto_approved_eligible | state.member_id | service_date_valid | state.provider_network | create_file | {"eligible": true, "coverage": 90, "deductible_met": true, "remaining_benefit": 5000} | "eligible_deductible_met" | 90 | "deductible_met" | 0.9 | payment-calculation |
    | preventive_approved | state.member_id | current_policy_year | state.provider_network | list_dir | {"eligible": true, "coverage": 100, "preventive_benefit": true, "no_deductible": true} | "preventive_covered" | 100 | "no_deductible_required" | 1.0 | auto-approval |
    | auto_approved_eligible | state.member_id | outside_policy_period | state.provider_network | grep_search | {"eligible": false, "reason": "service_date_invalid", "action": "deny"} | "service_date_invalid" | 0 | "not_applicable" | 1.0 | claim-denied |
    | requires_amount_review | state.member_id | within_policy_period | state.provider_network | create_file | {"eligible": true, "manual_review_required": true, "coverage": 80} | "eligible_needs_review" | 80 | "review_required" | 1.0 | manual-review |

@flow:chance_node
@scenario_id:manual-review
@context:human_review,complex_decision_making
Scenario Outline: Execute Manual Review Process
  Given claim requires manual review for <input:state.review_reason>
  And claim complexity is <input:state.complexity_level>
  And reviewer availability is <input:state.reviewer_available>
  And review queue size is <input:state.queue_size>
  When the manual review system assigns the claim
  Then it should execute tool <mcp_tool:name>
  And set review assignment to <output:state.review_assignment>
  And update estimated review time to <output:state.estimated_review_time>
  And set review priority to <output:state.review_priority>
  And transition to <transition>

  Examples: Manual review routing decision table (chance node with probabilities)
    | input:state.review_reason | input:state.complexity_level | input:state.reviewer_available | input:state.queue_size | mcp_tool:name | mcp_tool:output_sample | output:state.review_assignment | output:state.estimated_review_time | output:state.review_priority | probability | transition |
    | high_amount | complex | senior_reviewer | state.queue_size < 10 | semantic_search | {"assigned_to": "senior_reviewer_1", "expertise": "high_value_claims", "sla": "4hrs"} | "senior_reviewer_" + state.reviewer_id | "4 hours" | "urgent" | 0.7 | senior-review |
    | high_amount | complex | standard_reviewer | state.queue_size >= 10 | file_search | {"assigned_to": "standard_reviewer_3", "backup_support": true, "sla": "8hrs"} | "standard_reviewer_" + state.backup_id | "8 hours" | "high" | 0.2 | standard-review |
    | prior_authorization | medium | specialist_reviewer | state.queue_size | create_file | {"assigned_to": "medical_reviewer_2", "specialty": "authorization", "sla": "6hrs"} | "medical_specialist_" + state.specialty | "6 hours" | "medium" | 0.1 | specialist-review |
    | provider_network | simple | any_available | state.queue_size | grep_search | {"assigned_to": "network_reviewer_1", "automated_assist": true, "sla": "2hrs"} | "network_team_" + state.auto_assist | "2 hours" | "standard" | 0.8 | network-review |
    | documentation | medium | document_specialist | state.queue_size <= 5 | list_dir | {"assigned_to": "doc_specialist_1", "ai_assist": true, "sla": "3hrs"} | "documentation_team" | "3 hours" | "medium" | 0.6 | documentation-review |

@flow:decision_node
@scenario_id:payment-calculation
@context:benefit_calculation,payment_processing
Scenario Outline: Calculate Payment and Benefits
  Given eligibility result is <input:state.eligibility_result>
  And coverage percentage is <input:state.coverage_percentage>
  And deductible status is <input:state.deductible_status>
  And claim amount is <input:state.claim_amount>
  When the payment system calculates benefits
  Then it should execute tool <mcp_tool:name>
  And set payment amount to <output:state.payment_amount>
  And update member responsibility to <output:state.member_responsibility>
  And set payment status to <output:state.payment_status>
  And transition to <transition>

  Examples: Payment calculation decision table
    | input:state.eligibility_result | input:state.coverage_percentage | input:state.deductible_status | input:state.claim_amount | mcp_tool:name | mcp_tool:output_sample | output:state.payment_amount | output:state.member_responsibility | output:state.payment_status | probability | transition |
    | eligible_in_network | 80 | deductible_not_met | state.claim_amount | semantic_search | {"payment": 800, "deductible_applied": 200, "copay": 25, "total_covered": 800} | state.claim_amount * 0.8 - state.deductible_remaining | state.claim_amount - state.payment_amount | "payment_calculated" | 1.0 | payment-approval |
    | eligible_out_network | 60 | deductible_not_met | state.claim_amount | file_search | {"payment": 600, "deductible_applied": 400, "penalty": 200, "total_covered": 600} | state.claim_amount * 0.6 - state.out_network_penalty | state.claim_amount - state.payment_amount | "payment_calculated" | 1.0 | payment-approval |
    | eligible_deductible_met | 90 | deductible_met | state.claim_amount | create_file | {"payment": 900, "deductible_applied": 0, "copay": 10, "total_covered": 900} | state.claim_amount * 0.9 | state.claim_amount * 0.1 | "payment_calculated" | 1.0 | payment-approval |
    | preventive_covered | 100 | no_deductible_required | state.claim_amount | list_dir | {"payment": 1000, "deductible_applied": 0, "copay": 0, "total_covered": 1000} | state.claim_amount | 0 | "full_payment_approved" | 1.0 | auto-approval |

@flow:decision_node
@scenario_id:priority-review
@context:expedited_processing,high_value_claims
Scenario Outline: Process Priority Review Claims
  Given claim requires priority review for <input:state.priority_reason>
  And claim urgency level is <input:state.urgency_level>
  And medical necessity is <input:state.medical_necessity>
  And prior authorization status is <input:state.prior_auth_status>
  When the priority review system processes the claim
  Then it should execute tool <mcp_tool:name>
  And set review decision to <output:state.review_decision>
  And update approval status to <output:state.approval_status>
  And set follow_up_required to <output:state.follow_up_required>
  And transition to <transition>

  Examples: Priority review decision table
    | input:state.priority_reason | input:state.urgency_level | input:state.medical_necessity | input:state.prior_auth_status | mcp_tool:name | mcp_tool:output_sample | output:state.review_decision | output:state.approval_status | output:state.follow_up_required | probability | transition |
    | emergency_treatment | critical | medically_necessary | not_required | semantic_search | {"decision": "immediate_approval", "emergency_override": true, "payment_authorized": true} | "emergency_approved" | "approved" | false | 1.0 | payment-approval |
    | high_cost_procedure | high | medically_necessary | approved | file_search | {"decision": "approved_with_conditions", "conditions": ["follow_up_required"], "payment_authorized": true} | "conditionally_approved" | "approved" | true | 0.9 | payment-approval |
    | experimental_treatment | medium | under_review | pending | create_file | {"decision": "refer_to_medical_board", "specialist_review": true, "hold_payment": true} | "medical_board_review" | "pending" | true | 0.8 | medical-board-review |
    | high_cost_procedure | high | not_necessary | not_required | grep_search | {"decision": "denied_not_necessary", "reason": "medical_necessity_not_met", "appeal_available": true} | "denied_medical_necessity" | "denied" | false | 1.0 | claim-denied |
    | routine_high_cost | low | medically_necessary | expired | run_in_terminal | {"decision": "prior_auth_required", "action": "request_authorization", "hold_claim": true} | "prior_auth_needed" | "pending" | true | 1.0 | prior-auth-request |

@flow:end_node
@scenario_id:payment-approval
@context:payment_processing,claim_completion
Scenario Outline: Process Approved Payment
  Given payment amount is <input:state.payment_amount>
  And member responsibility is <input:state.member_responsibility>
  And payment status is <input:state.payment_status>
  And provider information is <input:state.provider_id>
  When the payment system processes the approved claim
  Then it should execute tool <mcp_tool:name>
  And set final payment status to <output:state.final_payment_status>
  And record transaction ID as <output:state.transaction_id>
  And update member account with <output:state.account_update>
  And set claim completion timestamp to <output:state.completion_timestamp>

  Examples: Payment approval completion table
    | input:state.payment_amount | input:state.member_responsibility | input:state.payment_status | input:state.provider_id | mcp_tool:name | mcp_tool:output_sample | output:state.final_payment_status | output:state.transaction_id | output:state.account_update | output:state.completion_timestamp | probability | transition |
    | state.payment_amount > 0 | state.member_responsibility | payment_calculated | state.provider_id | create_file | {"payment_processed": true, "transaction_id": "TXN-2025-001", "eft_scheduled": "2025-11-01"} | "payment_processed_successfully" | "TXN-" + generate_id() | "deductible_updated,claims_count_incremented" | new Date().toISOString() | 1.0 | |
    | state.payment_amount | 0 | full_payment_approved | state.provider_id | semantic_search | {"payment_processed": true, "transaction_id": "TXN-2025-002", "full_coverage": true} | "full_payment_completed" | "TXN-FULL-" + generate_id() | "preventive_benefit_used" | current_timestamp | 1.0 | |
    | state.payment_amount | state.copay_amount | payment_calculated | state.provider_id | file_search | {"payment_processed": true, "transaction_id": "TXN-2025-003", "member_billed": true} | "payment_with_copay_processed" | "TXN-COPAY-" + generate_id() | "copay_billed,balance_updated" | format_timestamp(now) | 0.9 | |

@flow:end_node
@scenario_id:auto-approval
@context:automated_processing,preventive_care
Scenario Outline: Process Auto-Approved Claims
  Given claim type is preventive or routine
  And coverage is <input:state.coverage_percentage>
  And auto-approval criteria met for <input:state.auto_approval_reason>
  When the automated system processes the claim
  Then it should execute tool <mcp_tool:name>
  And set auto processing status to <output:state.auto_processing_status>
  And record processing time as <output:state.processing_time>
  And update member benefits used to <output:state.benefits_used>
  And set completion status to <output:state.completion_status>

  Examples: Auto-approval completion table
    | input:state.coverage_percentage | input:state.auto_approval_reason | mcp_tool:name | mcp_tool:output_sample | output:state.auto_processing_status | output:state.processing_time | output:state.benefits_used | output:state.completion_status | probability | transition |
    | 100 | preventive_care | create_file | {"auto_processed": true, "processing_time": "45 seconds", "no_member_cost": true} | "preventive_auto_processed" | "45 seconds" | state.claim_amount | "completed_successfully" | 1.0 | |
    | state.coverage_percentage | routine_in_network | semantic_search | {"auto_processed": true, "processing_time": "2 minutes", "standard_copay": 25} | "routine_auto_processed" | "2 minutes" | calculate_benefits_used() | "completed_with_copay" | 0.9 | |
    | state.coverage_percentage | wellness_visit | list_dir | {"auto_processed": true, "processing_time": "30 seconds", "wellness_benefit": true} | "wellness_auto_processed" | "30 seconds" | wellness_benefit_amount | "wellness_completed" | 1.0 | |

@flow:end_node
@scenario_id:claim-denied
@context:claim_rejection,denial_processing
Scenario Outline: Process Denied Claims
  Given claim denial reason is <input:state.denial_reason>
  And appeal rights apply for <input:state.appeal_eligible>
  And denial category is <input:state.denial_category>
  When the denial system processes the rejection
  Then it should execute tool <mcp_tool:name>
  And set denial status to <output:state.denial_status>
  And create appeal information as <output:state.appeal_information>
  And record denial timestamp as <output:state.denial_timestamp>
  And set member notification status to <output:state.notification_status>

  Examples: Claim denial completion table
    | input:state.denial_reason | input:state.appeal_eligible | input:state.denial_category | mcp_tool:name | mcp_tool:output_sample | output:state.denial_status | output:state.appeal_information | output:state.denial_timestamp | output:state.notification_status | probability | transition |
    | policy_inactive | false | administrative | create_file | {"denied": true, "reason": "policy_not_active", "appeal": false, "member_notified": true} | "administratively_denied" | "no_appeal_available" | new Date().toISOString() | "member_notified" | 1.0 | |
    | medical_necessity | true | clinical | semantic_search | {"denied": true, "reason": "not_medically_necessary", "appeal": true, "appeal_deadline": "30_days"} | "clinically_denied" | "appeal_available_30_days" | current_timestamp | "appeal_notice_sent" | 1.0 | |
    | service_date_invalid | true | administrative | file_search | {"denied": true, "reason": "invalid_service_date", "appeal": true, "correction_possible": true} | "date_related_denial" | "appeal_or_correction_available" | format_timestamp(now) | "correction_notice_sent" | 0.9 | |
    | out_of_network | true | network | grep_search | {"denied": true, "reason": "provider_out_of_network", "appeal": true, "emergency_exception": "possible"} | "network_denial" | "appeal_with_emergency_exception" | denial_timestamp | "network_notice_sent" | 0.8 | |

@flow:transition_logic
@scenario_id:prior-auth-request
@context:authorization_workflow,external_processing
Scenario Outline: Handle Prior Authorization Requests
  Given prior authorization is required for <input:state.service_type>
  And request urgency is <input:state.request_urgency>
  And provider credentials are <input:state.provider_credentials>
  When the authorization system processes the request
  Then it should execute tool <mcp_tool:name>
  And set authorization status to <output:state.auth_status>
  And update estimated decision time to <output:state.decision_time>
  And set follow_up_action to <output:state.follow_up_action>
  And transition to <transition>

  Examples: Prior authorization decision table
    | input:state.service_type | input:state.request_urgency | input:state.provider_credentials | mcp_tool:name | mcp_tool:output_sample | output:state.auth_status | output:state.decision_time | output:state.follow_up_action | probability | transition |
    | emergency_procedure | urgent | verified_emergency | run_in_terminal | {"auth_status": "emergency_approved", "retroactive": true, "valid_period": "immediate"} | "emergency_authorization" | "immediate" | "retroactive_documentation" | 1.0 | payment-calculation |
    | elective_surgery | standard | network_provider | semantic_search | {"auth_status": "pending_review", "medical_review": true, "timeline": "5_business_days"} | "pending_medical_review" | "5 business days" | "await_medical_decision" | 0.8 | manual-review |
    | diagnostic_imaging | routine | in_network | file_search | {"auth_status": "auto_approved", "criteria_met": true, "valid_period": "30_days"} | "automatically_authorized" | "immediate" | "proceed_with_service" | 0.9 | eligibility-check |
    | experimental_treatment | standard | specialist_provider | create_file | {"auth_status": "requires_specialist_review", "expert_panel": true, "timeline": "10_business_days"} | "specialist_review_required" | "10 business days" | "expert_panel_review" | 1.0 | medical-board-review |
    | any | state.request_urgency | invalid_provider | run_in_terminal | {"auth_status": "provider_verification_failed", "action": "deny", "reason": "invalid_credentials"} | "provider_verification_failed" | "immediate" | "claim_denial_process" | 1.0 | claim-denied |

@flow:end_node
@scenario_id:medical-board-review
@context:expert_review,complex_medical_decisions
Scenario Outline: Process Medical Board Review
  Given case requires expert medical review for <input:state.medical_complexity>
  And board review type is <input:state.review_type>
  And clinical evidence quality is <input:state.evidence_quality>
  When the medical board completes their review
  Then it should execute tool <mcp_tool:name>
  And set board decision to <output:state.board_decision>
  And record expert recommendations as <output:state.expert_recommendations>
  And set final review status to <output:state.final_review_status>
  And update case completion time to <output:state.completion_time>

  Examples: Medical board review completion table
    | input:state.medical_complexity | input:state.review_type | input:state.evidence_quality | mcp_tool:name | mcp_tool:output_sample | output:state.board_decision | output:state.expert_recommendations | output:state.final_review_status | output:state.completion_time | probability | transition |
    | high_complexity | experimental_treatment | strong_evidence | semantic_search | {"decision": "approved_with_monitoring", "conditions": ["quarterly_reviews"], "specialist_required": true} | "approved_experimental" | "quarterly_monitoring_required" | "approved_with_conditions" | "14 business days" | 1.0 | |
    | medium_complexity | standard_procedure | adequate_evidence | create_file | {"decision": "approved_standard", "no_conditions": true, "standard_care": true} | "standard_approval" | "follow_standard_protocols" | "approved_unconditionally" | "7 business days" | 0.9 | |
    | high_complexity | investigational | insufficient_evidence | file_search | {"decision": "denied_insufficient_evidence", "appeal_process": true, "additional_data_needed": true} | "denied_evidence" | "request_additional_clinical_data" | "denied_with_appeal_option" | "10 business days" | 0.8 | |