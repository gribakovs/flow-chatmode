Feature: E-commerce Order Processing Flow with Inventory, Payment, Fraud Detection, and Shipping
  As an e-commerce platform
  I want to process orders through comprehensive validation and fulfillment
  So that customers receive products efficiently while maintaining security and inventory accuracy

@flow:context
Background: E-commerce Order Processing Context
  Given the workflow engine is initialized
  And the MCP tool registry is available
  And the order processing context is empty
  And all required tools are configured
  And inventory management system is accessible
  And payment gateway is operational
  And fraud detection service is enabled
  And shipping carrier APIs are available
  And customer database is synchronized
  And product catalog is current
  And pricing engine is active
  And tax calculation service is running
  And notification system is configured

@flow:decision_node
@scenario_id:order-intake
@context:order_validation,initial_processing
Scenario Outline: Process Initial Order Submission
  Given customer submits order with ID <input:state.order_id>
  And cart contains items <input:state.cart_items>
  And customer ID is <input:state.customer_id>
  And order total amount is <input:state.order_total>
  And customer tier is <input:state.customer_tier>
  And shipping address is <input:state.shipping_address>
  When the order intake system validates the submission
  Then it should execute tool <mcp_tool:name>
  And set order validation status to <output:state.validation_status>
  And update order priority to <output:state.order_priority>
  And set processing timestamp to <output:state.intake_timestamp>
  And assign order reference to <output:state.order_reference>
  And transition to <transition>

  Examples: Order intake decision table
    | input:state.order_id | input:state.cart_items | input:state.customer_id | input:state.order_total | input:state.customer_tier | input:state.shipping_address | mcp_tool:name | mcp_tool:output_sample | output:state.validation_status | output:state.order_priority | output:state.intake_timestamp | output:state.order_reference | probability | transition |
    | state.order_id | state.cart_items.length > 0 | "verified_customer" | state.order_total > 0 | "premium" | "verified_address" | semantic_search | {"order_valid": true, "items_validated": true, "customer_verified": true, "priority_processing": true} | "order_validated_successfully" | "high" | new Date().toISOString() | "ORD-" + generate_order_ref() | 1.0 | inventory-check |
    | state.order_id | state.cart_items.length > 0 | "verified_customer" | state.order_total > 0 | "standard" | "verified_address" | file_search | {"order_valid": true, "items_validated": true, "customer_verified": true, "standard_processing": true} | "order_validated_successfully" | "standard" | current_timestamp | "ORD-" + generate_order_ref() | 1.0 | inventory-check |
    | state.order_id | state.cart_items.length == 0 | state.customer_id | state.order_total | state.customer_tier | state.shipping_address | grep_search | {"order_invalid": true, "reason": "empty_cart", "validation_failed": true, "action_required": "add_items"} | "order_validation_failed" | "low" | error_timestamp | null | 0.9 | order-rejected |
    | state.order_id | state.cart_items | "unverified_customer" | state.order_total > 1000 | state.customer_tier | state.shipping_address | run_in_terminal | {"order_flagged": true, "reason": "high_value_unverified", "manual_review": true, "fraud_check": "required"} | "order_requires_verification" | "urgent" | verification_timestamp | "ORD-" + generate_order_ref() | 0.8 | fraud-detection |
    | state.order_id | state.cart_items | state.customer_id | state.order_total <= 0 | state.customer_tier | state.shipping_address | create_file | {"order_invalid": true, "reason": "invalid_total", "validation_failed": true, "pricing_error": true} | "order_pricing_error" | "immediate" | error_timestamp | null | 1.0 | order-rejected |
    | state.order_id | state.cart_items | state.customer_id | state.order_total | state.customer_tier | "invalid_shipping_address" | grep_search | {"address_invalid": true, "shipping_validation_failed": true, "address_correction_required": true, "order_held": true} | "shipping_address_invalid" | "medium" | address_error_timestamp | "ORD-" + generate_order_ref() | 0.9 | address-validation-required |
    | state.order_id | state.cart_items | "blocked_customer" | state.order_total | state.customer_tier | state.shipping_address | run_in_terminal | {"customer_blocked": true, "reason": "account_restrictions", "order_declined": true, "support_escalation": true} | "customer_account_blocked" | "urgent" | blocked_timestamp | null | 1.0 | customer-blocked |

@flow:decision_node
@scenario_id:inventory-check
@context:inventory_validation,stock_management
Scenario Outline: Validate Product Inventory Availability
  Given order contains products <input:state.cart_items>
  And requested quantities are <input:state.requested_quantities>
  And warehouse locations are <input:state.warehouse_locations>
  And inventory buffer settings are <input:state.inventory_buffer>
  And product availability status is <input:state.product_availability>
  When the inventory system checks product availability
  Then it should execute tool <mcp_tool:name>
  And set inventory status to <output:state.inventory_status>
  And update available quantities to <output:state.available_quantities>
  And set allocation result to <output:state.allocation_result>
  And record inventory timestamp as <output:state.inventory_timestamp>
  And transition to <transition>

  Examples: Inventory validation decision table
    | input:state.cart_items | input:state.requested_quantities | input:state.warehouse_locations | input:state.inventory_buffer | input:state.product_availability | mcp_tool:name | mcp_tool:output_sample | output:state.inventory_status | output:state.available_quantities | output:state.allocation_result | output:state.inventory_timestamp | probability | transition |
    | state.cart_items | state.requested_quantities | "primary_warehouse" | "sufficient_buffer" | "all_available" | semantic_search | {"inventory_sufficient": true, "allocation_success": true, "reserved_items": state.cart_items, "fulfillment_ready": true} | "inventory_available" | state.requested_quantities | "full_allocation_successful" | new Date().toISOString() | 1.0 | payment-processing |
    | state.cart_items | state.requested_quantities | "multiple_warehouses" | "adequate_buffer" | "partial_available" | file_search | {"inventory_partial": true, "available_items": "subset", "backorder_required": true, "split_shipment": true} | "partial_inventory_available" | calculate_partial_quantities(state.requested_quantities) | "partial_allocation_with_backorder" | current_timestamp | 0.8 | partial-fulfillment |
    | state.cart_items | state.requested_quantities | state.warehouse_locations | "low_buffer" | "limited_availability" | grep_search | {"inventory_low": true, "reservation_held": true, "priority_check": true, "alternative_products": "suggested"} | "low_inventory_reserved" | state.requested_quantities | "priority_allocation_pending" | priority_timestamp | 0.9 | inventory-prioritization |
    | state.cart_items | state.requested_quantities | state.warehouse_locations | state.inventory_buffer | "out_of_stock" | run_in_terminal | {"inventory_unavailable": true, "out_of_stock": true, "estimated_restock": "7-14_days", "notification_required": true} | "inventory_out_of_stock" | 0 | "allocation_failed" | oos_timestamp | 1.0 | out-of-stock |
    | state.cart_items | state.requested_quantities > state.max_order_limit | state.warehouse_locations | state.inventory_buffer | state.product_availability | create_file | {"order_exceeds_limit": true, "quantity_violation": true, "bulk_order_review": true, "approval_required": true} | "quantity_limit_exceeded" | state.max_order_limit | "allocation_requires_approval" | limit_timestamp | 0.9 | bulk-order-review |
    | state.cart_items | state.requested_quantities | "warehouse_system_down" | state.inventory_buffer | state.product_availability | run_in_terminal | {"inventory_system_unavailable": true, "manual_check_required": true, "order_held": true, "system_recovery_pending": true} | "inventory_system_error" | "unknown" | "allocation_pending_system_recovery" | system_error_timestamp | 1.0 | inventory-system-error |
    | "discontinued_products" | state.requested_quantities | state.warehouse_locations | state.inventory_buffer | "product_discontinued" | semantic_search | {"products_discontinued": true, "alternatives_suggested": true, "order_modification_required": true, "customer_notification": true} | "products_no_longer_available" | 0 | "allocation_failed_discontinued" | discontinued_timestamp | 1.0 | product-discontinued |

@flow:chance_node
@scenario_id:fraud-detection
@context:fraud_analysis,risk_assessment
Scenario Outline: Execute Fraud Detection Analysis
  Given customer profile shows <input:state.customer_profile>
  And order characteristics are <input:state.order_characteristics>
  And payment method is <input:state.payment_method>
  And shipping vs billing address match is <input:state.address_match>
  And customer behavior score is <input:state.behavior_score>
  When the fraud detection system analyzes the order
  Then it should execute tool <mcp_tool:name>
  And set fraud risk score to <output:state.fraud_score>
  And update risk assessment to <output:state.risk_assessment>
  And set verification requirements to <output:state.verification_requirements>
  And record fraud analysis timestamp as <output:state.fraud_timestamp>
  And transition to <transition>

  Examples: Fraud detection decision table (chance node with probabilities)
    | input:state.customer_profile | input:state.order_characteristics | input:state.payment_method | input:state.address_match | input:state.behavior_score | mcp_tool:name | mcp_tool:output_sample | output:state.fraud_score | output:state.risk_assessment | output:state.verification_requirements | output:state.fraud_timestamp | probability | transition |
    | "trusted_customer" | "normal_order_pattern" | "verified_card" | "addresses_match" | state.behavior_score > 0.8 | semantic_search | {"fraud_score": 0.1, "risk_level": "low", "automated_approval": true, "verification": "none_required"} | 0.1 | "low_risk_approved" | "none_required" | new Date().toISOString() | 0.7 | payment-processing |
    | "new_customer" | "high_value_order" | "new_payment_method" | "addresses_different" | state.behavior_score < 0.5 | file_search | {"fraud_score": 0.7, "risk_level": "medium", "manual_review": true, "verification": "phone_verification"} | 0.7 | "medium_risk_review_required" | "phone_verification_required" | medium_risk_timestamp | 0.2 | manual-fraud-review |
    | "flagged_customer" | "suspicious_pattern" | "high_risk_card" | "addresses_mismatch" | state.behavior_score < 0.3 | grep_search | {"fraud_score": 0.9, "risk_level": "high", "order_blocked": true, "verification": "full_identity_check"} | 0.9 | "high_risk_blocked" | "full_identity_verification" | high_risk_timestamp | 0.08 | fraud-blocked |
    | "returning_customer" | "unusual_order_size" | "saved_payment_method" | "addresses_match" | state.behavior_score >= 0.6 | run_in_terminal | {"fraud_score": 0.4, "risk_level": "medium_low", "enhanced_monitoring": true, "verification": "email_confirmation"} | 0.4 | "medium_low_risk_monitored" | "email_confirmation_required" | monitoring_timestamp | 0.02 | enhanced-verification |
    | "guest_customer" | "large_electronics_order" | "gift_card_payment" | "different_countries" | state.behavior_score < 0.4 | grep_search | {"fraud_score": 0.85, "risk_level": "very_high", "gift_card_fraud_pattern": true, "verification": "identity_verification"} | 0.85 | "very_high_risk_gift_card_fraud" | "full_identity_verification_required" | gift_card_fraud_timestamp | 0.05 | fraud-blocked |
    | "multiple_accounts_same_device" | "velocity_fraud_pattern" | "rapid_payment_attempts" | "addresses_rotating" | state.behavior_score < 0.2 | semantic_search | {"fraud_score": 0.95, "risk_level": "critical", "velocity_fraud_detected": true, "account_linking": "suspicious"} | 0.95 | "critical_risk_velocity_fraud" | "immediate_investigation_required" | velocity_fraud_timestamp | 0.03 | fraud-blocked |

@flow:decision_node
@scenario_id:payment-processing
@context:payment_authorization,transaction_processing
Scenario Outline: Process Payment Authorization
  Given payment method is <input:state.payment_method>
  And payment amount is <input:state.payment_amount>
  And customer billing information is <input:state.billing_info>
  And fraud score is <input:state.fraud_score>
  And payment gateway status is <input:state.gateway_status>
  When the payment system processes the transaction
  Then it should execute tool <mcp_tool:name>
  And set payment authorization to <output:state.payment_authorization>
  And update transaction ID to <output:state.transaction_id>
  And set payment status to <output:state.payment_status>
  And record payment timestamp as <output:state.payment_timestamp>
  And transition to <transition>

  Examples: Payment processing decision table
    | input:state.payment_method | input:state.payment_amount | input:state.billing_info | input:state.fraud_score | input:state.gateway_status | mcp_tool:name | mcp_tool:output_sample | output:state.payment_authorization | output:state.transaction_id | output:state.payment_status | output:state.payment_timestamp | probability | transition |
    | "credit_card" | state.payment_amount | "verified_billing" | state.fraud_score < 0.3 | "gateway_online" | semantic_search | {"payment_approved": true, "auth_code": "AUTH123", "transaction_id": "TXN-001", "gateway_response": "approved"} | "payment_authorized_successfully" | "TXN-" + generate_transaction_id() | "payment_completed" | new Date().toISOString() | 1.0 | shipping-coordination |
    | "paypal" | state.payment_amount | "paypal_verified" | state.fraud_score < 0.4 | "gateway_online" | file_search | {"paypal_approved": true, "paypal_transaction": "PP-123", "instant_payment": true, "verified_account": true} | "paypal_payment_authorized" | "PP-" + generate_paypal_id() | "payment_completed" | paypal_timestamp | 1.0 | shipping-coordination |
    | "bank_transfer" | state.payment_amount | "verified_bank_account" | state.fraud_score < 0.2 | "gateway_online" | create_file | {"bank_transfer_initiated": true, "clearing_time": "1-3_days", "payment_pending": true, "hold_shipment": true} | "bank_transfer_pending" | "BT-" + generate_bank_ref() | "payment_pending_clearance" | bank_timestamp | 1.0 | payment-pending |
    | state.payment_method | state.payment_amount | state.billing_info | state.fraud_score >= 0.7 | state.gateway_status | run_in_terminal | {"payment_declined": true, "reason": "high_fraud_score", "transaction_blocked": true, "review_required": true} | "payment_declined_fraud" | null | "payment_failed" | decline_timestamp | 0.9 | payment-failed |
    | state.payment_method | state.payment_amount | "invalid_billing" | state.fraud_score | "gateway_online" | grep_search | {"payment_declined": true, "reason": "billing_verification_failed", "card_declined": true, "retry_allowed": true} | "payment_declined_billing" | null | "payment_failed" | billing_error_timestamp | 1.0 | payment-failed |
    | state.payment_method | state.payment_amount | state.billing_info | state.fraud_score | "gateway_offline" | run_in_terminal | {"gateway_error": true, "payment_processing_unavailable": true, "retry_later": true, "system_maintenance": true} | "payment_gateway_error" | null | "payment_system_error" | gateway_error_timestamp | 1.0 | payment-retry |
    | "expired_credit_card" | state.payment_amount | state.billing_info | state.fraud_score | "gateway_online" | file_search | {"card_expired": true, "payment_declined": true, "update_payment_method": true, "retry_with_new_card": true} | "payment_declined_expired_card" | null | "payment_failed" | expired_card_timestamp | 1.0 | payment-failed |
    | "international_card" | state.payment_amount | state.billing_info | state.fraud_score | "gateway_online" | grep_search | {"international_restrictions": true, "currency_conversion_required": true, "additional_fees_apply": true, "approval_pending": true} | "international_payment_processing" | "INTL-" + generate_transaction_id() | "payment_pending_conversion" | international_timestamp | 0.8 | payment-pending |

@flow:decision_node
@scenario_id:shipping-coordination
@context:shipping_orchestration,carrier_selection
Scenario Outline: Coordinate Order Shipping and Fulfillment
  Given shipping address is <input:state.shipping_address>
  And package dimensions are <input:state.package_dimensions>
  And shipping method preference is <input:state.shipping_method>
  And delivery timeline requirement is <input:state.delivery_timeline>
  And customer tier is <input:state.customer_tier>
  And carrier availability is <input:state.carrier_availability>
  When the shipping system coordinates fulfillment
  Then it should execute tool <mcp_tool:name>
  And set shipping carrier to <output:state.selected_carrier>
  And update estimated delivery to <output:state.estimated_delivery>
  And set tracking reference to <output:state.tracking_reference>
  And record shipping timestamp as <output:state.shipping_timestamp>
  And transition to <transition>

  Examples: Shipping coordination decision table
    | input:state.shipping_address | input:state.package_dimensions | input:state.shipping_method | input:state.delivery_timeline | input:state.customer_tier | input:state.carrier_availability | mcp_tool:name | mcp_tool:output_sample | output:state.selected_carrier | output:state.estimated_delivery | output:state.tracking_reference | output:state.shipping_timestamp | probability | transition |
    | "domestic_address" | "standard_package" | "express_delivery" | "next_day" | "premium" | "express_available" | semantic_search | {"carrier_selected": "FedEx_Express", "service": "overnight", "tracking": "FX123", "delivery_guaranteed": true} | "FedEx_Express" | calculate_next_day_delivery() | "FX-" + generate_tracking_number() | new Date().toISOString() | 1.0 | order-fulfillment |
    | "domestic_address" | "standard_package" | "standard_shipping" | "3-5_days" | "standard" | "standard_carriers_available" | file_search | {"carrier_selected": "UPS_Ground", "service": "ground", "tracking": "UPS456", "cost_optimized": true} | "UPS_Ground" | calculate_standard_delivery(3, 5) | "UPS-" + generate_tracking_number() | standard_timestamp | 1.0 | order-fulfillment |
    | "international_address" | "standard_package" | "international_shipping" | "7-14_days" | state.customer_tier | "international_available" | grep_search | {"carrier_selected": "DHL_International", "service": "international", "tracking": "DHL789", "customs_required": true} | "DHL_International" | calculate_international_delivery(7, 14) | "DHL-" + generate_tracking_number() | international_timestamp | 1.0 | customs-processing |
    | state.shipping_address | "oversized_package" | state.shipping_method | state.delivery_timeline | state.customer_tier | "freight_required" | run_in_terminal | {"freight_shipping": true, "carrier_selected": "Freight_Carrier", "special_handling": true, "delivery_appointment": "required"} | "Freight_Carrier" | calculate_freight_delivery() | "FR-" + generate_freight_reference() | freight_timestamp | 1.0 | freight-coordination |
    | "remote_address" | state.package_dimensions | state.shipping_method | state.delivery_timeline | state.customer_tier | "limited_carrier_access" | create_file | {"limited_shipping": true, "carrier_selected": "USPS", "extended_delivery": true, "additional_handling": true} | "USPS" | calculate_remote_delivery() | "USPS-" + generate_postal_reference() | remote_timestamp | 0.9 | special-handling |

@flow:decision_node
@scenario_id:partial-fulfillment
@context:split_shipment,backorder_management
Scenario Outline: Handle Partial Order Fulfillment
  Given available items are <input:state.available_items>
  And backordered items are <input:state.backordered_items>
  And customer preference is <input:state.fulfillment_preference>
  And estimated restock date is <input:state.restock_date>
  When the partial fulfillment system processes the split order
  Then it should execute tool <mcp_tool:name>
  And set fulfillment strategy to <output:state.fulfillment_strategy>
  And update shipment plan to <output:state.shipment_plan>
  And set customer notification to <output:state.customer_notification>
  And record split timestamp as <output:state.split_timestamp>
  And transition to <transition>

  Examples: Partial fulfillment decision table
    | input:state.available_items | input:state.backordered_items | input:state.fulfillment_preference | input:state.restock_date | mcp_tool:name | mcp_tool:output_sample | output:state.fulfillment_strategy | output:state.shipment_plan | output:state.customer_notification | output:state.split_timestamp | probability | transition |
    | state.available_items | state.backordered_items | "ship_available_immediately" | state.restock_date | semantic_search | {"split_shipment": true, "immediate_ship": state.available_items, "backorder_created": true, "customer_notified": true} | "immediate_partial_shipment" | "ship_available_hold_backorder" | "partial_shipment_notification_sent" | new Date().toISOString() | 1.0 | shipping-coordination |
    | state.available_items | state.backordered_items | "wait_for_complete_order" | state.restock_date <= 7 | file_search | {"wait_strategy": true, "hold_all_items": true, "estimated_ship_date": state.restock_date, "customer_updated": true} | "wait_for_complete_fulfillment" | "hold_all_items_until_complete" | "delay_notification_sent" | wait_timestamp | 0.8 | inventory-hold |
    | state.available_items | state.backordered_items | "cancel_backordered_items" | state.restock_date | grep_search | {"cancel_backorder": true, "ship_available_only": true, "refund_backorder": true, "order_modified": true} | "cancel_backorder_ship_available" | "ship_available_refund_backorder" | "order_modification_notification" | cancel_timestamp | 0.9 | payment-adjustment |
    | state.available_items | state.backordered_items | state.fulfillment_preference | state.restock_date > 30 | run_in_terminal | {"long_backorder": true, "customer_choice_required": true, "alternative_products": "suggested", "expedited_sourcing": true} | "long_backorder_customer_choice" | "suggest_alternatives_expedite_sourcing" | "long_delay_choice_notification" | long_delay_timestamp | 1.0 | customer-choice-required |

@flow:decision_node
@scenario_id:manual-fraud-review
@context:human_review,fraud_investigation
Scenario Outline: Execute Manual Fraud Review Process
  Given fraud score is <input:state.fraud_score>
  And order details are <input:state.order_details>
  And customer history is <input:state.customer_history>
  And reviewer availability is <input:state.reviewer_availability>
  And review priority is <input:state.review_priority>
  When the manual fraud review system assigns the case
  Then it should execute tool <mcp_tool:name>
  And set review assignment to <output:state.review_assignment>
  And update review status to <output:state.review_status>
  And set estimated review time to <output:state.estimated_review_time>
  And record review timestamp as <output:state.review_timestamp>
  And transition to <transition>

  Examples: Manual fraud review decision table
    | input:state.fraud_score | input:state.order_details | input:state.customer_history | input:state.reviewer_availability | input:state.review_priority | mcp_tool:name | mcp_tool:output_sample | output:state.review_assignment | output:state.review_status | output:state.estimated_review_time | output:state.review_timestamp | probability | transition |
    | state.fraud_score >= 0.6 | "high_value_order" | "clean_history" | "senior_reviewer_available" | "high" | semantic_search | {"reviewer_assigned": "senior_fraud_analyst_1", "review_type": "comprehensive", "sla": "2_hours", "decision_pending": true} | "senior_reviewer_" + state.reviewer_id | "comprehensive_review_in_progress" | "2 hours" | new Date().toISOString() | 1.0 | fraud-review-decision |
    | state.fraud_score < 0.6 | "standard_order" | "positive_history" | "standard_reviewer_available" | "medium" | file_search | {"reviewer_assigned": "fraud_analyst_2", "review_type": "standard", "sla": "4_hours", "automated_assist": true} | "standard_reviewer_" + state.reviewer_id | "standard_review_in_progress" | "4 hours" | standard_review_timestamp | 0.9 | fraud-review-decision |
    | state.fraud_score | state.order_details | "flagged_history" | state.reviewer_availability | "urgent" | run_in_terminal | {"escalated_review": true, "senior_management": true, "immediate_attention": true, "legal_consultation": "considered"} | "escalated_management_review" | "urgent_escalated_review" | "1 hour" | urgent_timestamp | 1.0 | fraud-escalation |

@flow:decision_node
@scenario_id:fraud-review-decision
@context:fraud_review_outcome,decision_processing
Scenario Outline: Process Fraud Review Decision
  Given fraud review result is <input:state.review_result>
  And reviewer confidence level is <input:state.confidence_level>
  And additional verification completed is <input:state.additional_verification>
  And order risk assessment is <input:state.final_risk_assessment>
  When the fraud review decision system processes the outcome
  Then it should execute tool <mcp_tool:name>
  And set review decision to <output:state.review_decision>
  And update order status to <output:state.order_status>
  And set next action to <output:state.next_action>
  And record decision timestamp as <output:state.decision_timestamp>
  And transition to <transition>

  Examples: Fraud review decision table
    | input:state.review_result | input:state.confidence_level | input:state.additional_verification | input:state.final_risk_assessment | mcp_tool:name | mcp_tool:output_sample | output:state.review_decision | output:state.order_status | output:state.next_action | output:state.decision_timestamp | probability | transition |
    | "approved" | "high_confidence" | "identity_verified" | "low_risk" | semantic_search | {"fraud_review_passed": true, "order_approved": true, "processing_resumed": true, "confidence_documented": true} | "fraud_review_approved" | "approved_for_processing" | "proceed_to_payment" | new Date().toISOString() | 1.0 | payment-processing |
    | "rejected" | "high_confidence" | "identity_failed" | "high_risk" | run_in_terminal | {"fraud_review_failed": true, "order_blocked": true, "customer_flagged": true, "investigation_escalated": true} | "fraud_review_rejected" | "permanently_blocked" | "block_customer_and_investigate" | rejection_timestamp | 1.0 | fraud-blocked |
    | "requires_additional_verification" | "medium_confidence" | "partial_verification" | "medium_risk" | file_search | {"additional_verification_required": true, "enhanced_checks_needed": true, "conditional_approval": true, "monitoring_enhanced": true} | "conditional_approval_with_verification" | "verification_required" | "request_additional_documentation" | verification_timestamp | 0.8 | enhanced-verification |

@flow:decision_node
@scenario_id:enhanced-verification
@context:additional_verification,identity_confirmation
Scenario Outline: Execute Enhanced Customer Verification
  Given verification requirements are <input:state.verification_requirements>
  And customer response is <input:state.customer_response>
  And verification method used is <input:state.verification_method>
  And verification result is <input:state.verification_result>
  When the enhanced verification system processes the check
  Then it should execute tool <mcp_tool:name>
  And set verification outcome to <output:state.verification_outcome>
  And update customer trust level to <output:state.trust_level>
  And set processing authorization to <output:state.processing_authorization>
  And record verification timestamp as <output:state.verification_timestamp>
  And transition to <transition>

  Examples: Enhanced verification decision table
    | input:state.verification_requirements | input:state.customer_response | input:state.verification_method | input:state.verification_result | mcp_tool:name | mcp_tool:output_sample | output:state.verification_outcome | output:state.trust_level | output:state.processing_authorization | output:state.verification_timestamp | probability | transition |
    | "phone_verification" | "customer_answered" | "phone_call" | "identity_confirmed" | semantic_search | {"phone_verification_passed": true, "identity_confirmed": true, "trust_level_increased": true, "order_approved": true} | "phone_verification_successful" | "verified_customer" | "authorized_to_proceed" | new Date().toISOString() | 1.0 | payment-processing |
    | "document_verification" | "documents_provided" | "id_document_check" | "documents_authentic" | file_search | {"document_verification_passed": true, "id_authentic": true, "address_confirmed": true, "fraud_risk_reduced": true} | "document_verification_successful" | "highly_verified_customer" | "authorized_to_proceed" | document_timestamp | 1.0 | payment-processing |
    | "email_confirmation" | "email_confirmed" | "email_verification" | "email_verified" | grep_search | {"email_verification_passed": true, "email_ownership_confirmed": true, "basic_verification_complete": true} | "email_verification_successful" | "email_verified_customer" | "authorized_to_proceed" | email_timestamp | 1.0 | payment-processing |
    | state.verification_requirements | "customer_unresponsive" | state.verification_method | "verification_timeout" | run_in_terminal | {"verification_failed": true, "customer_unresponsive": true, "order_cancelled": true, "timeout_reached": true} | "verification_failed_timeout" | "unverified_customer" | "order_cancellation_required" | timeout_timestamp | 0.9 | order-cancelled |

@flow:decision_node
@scenario_id:inventory-prioritization
@context:inventory_allocation,priority_management
Scenario Outline: Handle Inventory Priority Allocation
  Given inventory shortage level is <input:state.shortage_level>
  And customer priority tier is <input:state.customer_tier>
  And order value is <input:state.order_value>
  And alternative inventory locations are <input:state.alternative_locations>
  When the inventory prioritization system allocates stock
  Then it should execute tool <mcp_tool:name>
  And set allocation decision to <output:state.allocation_decision>
  And update inventory reservation to <output:state.inventory_reservation>
  And set priority ranking to <output:state.priority_ranking>
  And record allocation timestamp as <output:state.allocation_timestamp>
  And transition to <transition>

  Examples: Inventory prioritization decision table
    | input:state.shortage_level | input:state.customer_tier | input:state.order_value | input:state.alternative_locations | mcp_tool:name | mcp_tool:output_sample | output:state.allocation_decision | output:state.inventory_reservation | output:state.priority_ranking | output:state.allocation_timestamp | probability | transition |
    | "low_stock" | "premium" | state.order_value > 500 | "alternative_warehouse_available" | semantic_search | {"priority_allocation_approved": true, "premium_customer_priority": true, "alternative_sourcing": true, "inventory_reserved": true} | "priority_allocation_granted" | "reserved_from_alternative_warehouse" | "high_priority" | new Date().toISOString() | 1.0 | payment-processing |
    | "critical_stock" | "standard" | state.order_value < 100 | "no_alternatives" | file_search | {"allocation_denied": true, "insufficient_priority": true, "backorder_offered": true, "alternative_products_suggested": true} | "allocation_denied_low_priority" | "no_reservation_made" | "low_priority" | denial_timestamp | 0.8 | out-of-stock |
    | "moderate_stock" | "vip" | state.order_value | state.alternative_locations | grep_search | {"vip_priority_allocation": true, "emergency_sourcing": true, "expedited_fulfillment": true, "inventory_secured": true} | "vip_emergency_allocation" | "emergency_inventory_reserved" | "vip_priority" | vip_timestamp | 1.0 | payment-processing |

@flow:decision_node
@scenario_id:bulk-order-review
@context:large_order_validation,quantity_approval
Scenario Outline: Review Bulk Order Requests
  Given bulk order quantity is <input:state.bulk_quantity>
  And customer account type is <input:state.account_type>
  And bulk pricing eligibility is <input:state.bulk_pricing_eligible>
  And inventory impact assessment is <input:state.inventory_impact>
  When the bulk order review system evaluates the request
  Then it should execute tool <mcp_tool:name>
  And set bulk approval status to <output:state.bulk_approval>
  And update pricing structure to <output:state.pricing_structure>
  And set fulfillment plan to <output:state.fulfillment_plan>
  And record bulk review timestamp as <output:state.bulk_review_timestamp>
  And transition to <transition>

  Examples: Bulk order review decision table
    | input:state.bulk_quantity | input:state.account_type | input:state.bulk_pricing_eligible | input:state.inventory_impact | mcp_tool:name | mcp_tool:output_sample | output:state.bulk_approval | output:state.pricing_structure | output:state.fulfillment_plan | output:state.bulk_review_timestamp | probability | transition |
    | state.bulk_quantity > 100 | "business_account" | "eligible_for_bulk_pricing" | "manageable_impact" | semantic_search | {"bulk_order_approved": true, "bulk_pricing_applied": true, "special_fulfillment": true, "business_discount": "applied"} | "bulk_order_approved" | "bulk_pricing_tier_applied" | "special_fulfillment_processing" | new Date().toISOString() | 1.0 | payment-processing |
    | state.bulk_quantity > 500 | "individual_account" | "not_eligible" | "significant_impact" | run_in_terminal | {"bulk_order_requires_approval": true, "manual_review_required": true, "inventory_manager_consulted": true, "special_terms_needed": true} | "manual_approval_required" | "standard_pricing_pending_review" | "management_approval_required" | approval_timestamp | 0.8 | management-approval |
    | state.bulk_quantity | state.account_type | state.bulk_pricing_eligible | "severe_inventory_impact" | file_search | {"bulk_order_denied": true, "inventory_insufficient": true, "alternative_quantities_suggested": true, "special_order_option": true} | "bulk_order_denied_inventory" | "standard_pricing_maintained" | "suggest_reduced_quantity_or_special_order" | denial_timestamp | 1.0 | inventory-insufficient |

@flow:decision_node
@scenario_id:payment-adjustment
@context:payment_modification,refund_processing
Scenario Outline: Process Payment Adjustments for Order Changes
  Given payment adjustment type is <input:state.adjustment_type>
  And adjustment amount is <input:state.adjustment_amount>
  And original payment method is <input:state.original_payment_method>
  And customer approval is <input:state.customer_approval>
  When the payment adjustment system processes the change
  Then it should execute tool <mcp_tool:name>
  And set adjustment status to <output:state.adjustment_status>
  And update payment record to <output:state.payment_record>
  And set refund processing to <output:state.refund_processing>
  And record adjustment timestamp as <output:state.adjustment_timestamp>
  And transition to <transition>

  Examples: Payment adjustment decision table
    | input:state.adjustment_type | input:state.adjustment_amount | input:state.original_payment_method | input:state.customer_approval | mcp_tool:name | mcp_tool:output_sample | output:state.adjustment_status | output:state.payment_record | output:state.refund_processing | output:state.adjustment_timestamp | probability | transition |
    | "partial_refund" | state.adjustment_amount > 0 | "credit_card" | "customer_approved" | semantic_search | {"partial_refund_processed": true, "refund_amount": state.adjustment_amount, "remaining_charge": "calculated", "customer_notified": true} | "partial_refund_completed" | "payment_record_updated_with_refund" | "refund_issued_to_original_method" | new Date().toISOString() | 1.0 | shipping-coordination |
    | "price_adjustment" | state.adjustment_amount | "paypal" | "customer_approved" | file_search | {"price_adjustment_applied": true, "new_total_calculated": true, "additional_charge_required": false, "customer_notified": true} | "price_adjustment_completed" | "payment_record_updated_with_adjustment" | "no_refund_required" | adjustment_timestamp | 1.0 | shipping-coordination |
    | "full_refund" | state.adjustment_amount | state.original_payment_method | "customer_requested" | run_in_terminal | {"full_refund_initiated": true, "order_cancelled": true, "inventory_released": true, "refund_processing": "initiated"} | "full_refund_processing" | "payment_fully_refunded" | "full_refund_issued" | refund_timestamp | 1.0 | order-cancelled |

@flow:end_node
@scenario_id:order-fulfillment
@context:successful_completion,order_shipped
Scenario Outline: Complete Successful Order Fulfillment
  Given order fulfillment status is <input:state.fulfillment_status>
  And shipping carrier is <input:state.selected_carrier>
  And tracking information is <input:state.tracking_reference>
  And estimated delivery is <input:state.estimated_delivery>
  When the fulfillment system completes the order
  Then it should execute tool <mcp_tool:name>
  And set final order status to <output:state.final_order_status>
  And update customer notification to <output:state.customer_notification>
  And record completion timestamp as <output:state.completion_timestamp>
  And set delivery tracking to <output:state.delivery_tracking>

  Examples: Order fulfillment completion table
    | input:state.fulfillment_status | input:state.selected_carrier | input:state.tracking_reference | input:state.estimated_delivery | mcp_tool:name | mcp_tool:output_sample | output:state.final_order_status | output:state.customer_notification | output:state.completion_timestamp | output:state.delivery_tracking | probability | transition |
    | "ready_to_ship" | state.selected_carrier | state.tracking_reference | state.estimated_delivery | create_file | {"order_shipped": true, "tracking_active": true, "customer_notified": true, "delivery_monitoring": "enabled"} | "order_shipped_successfully" | "shipping_confirmation_sent" | new Date().toISOString() | "tracking_enabled_" + state.tracking_reference | 1.0 | |

@flow:end_node
@scenario_id:order-rejected
@context:order_rejection,validation_failure
Scenario Outline: Handle Order Rejection
  Given order rejection reason is <input:state.rejection_reason>
  And validation errors are <input:state.validation_errors>
  And customer notification requirement is <input:state.notification_required>
  When the order rejection system processes the failure
  Then it should execute tool <mcp_tool:name>
  And set rejection status to <output:state.rejection_status>
  And create customer notification as <output:state.customer_notification>
  And record rejection timestamp as <output:state.rejection_timestamp>
  And set retry guidance to <output:state.retry_guidance>

  Examples: Order rejection completion table
    | input:state.rejection_reason | input:state.validation_errors | input:state.notification_required | mcp_tool:name | mcp_tool:output_sample | output:state.rejection_status | output:state.customer_notification | output:state.rejection_timestamp | output:state.retry_guidance | probability | transition |
    | state.rejection_reason | state.validation_errors | true | create_file | {"order_rejected": true, "reason_logged": true, "customer_notified": true, "retry_guidance": "provided"} | "order_rejected_" + state.rejection_reason | "rejection_notification_sent" | new Date().toISOString() | "retry_with_corrections_suggested" | 1.0 | |

@flow:end_node
@scenario_id:fraud-blocked
@context:fraud_prevention,order_blocked
Scenario Outline: Handle Fraud-Blocked Orders
  Given fraud blocking reason is <input:state.fraud_blocking_reason>
  And fraud score is <input:state.fraud_score>
  And security alert level is <input:state.security_alert_level>
  When the fraud blocking system processes the violation
  Then it should execute tool <mcp_tool:name>
  And set blocking status to <output:state.blocking_status>
  And create security incident as <output:state.security_incident>
  And record fraud timestamp as <output:state.fraud_timestamp>
  And set investigation flag to <output:state.investigation_required>

  Examples: Fraud blocking completion table
    | input:state.fraud_blocking_reason | input:state.fraud_score | input:state.security_alert_level | mcp_tool:name | mcp_tool:output_sample | output:state.blocking_status | output:state.security_incident | output:state.fraud_timestamp | output:state.investigation_required | probability | transition |
    | "high_fraud_score" | state.fraud_score | "high" | run_in_terminal | {"fraud_blocked": true, "incident_created": "FRAUD-001", "investigation_initiated": true, "customer_flagged": true} | "order_blocked_for_fraud" | "FRAUD-" + generate_incident_id() | new Date().toISOString() | "full_investigation_required" | 1.0 | |

@flow:end_node
@scenario_id:out-of-stock
@context:inventory_unavailable,stock_shortage
Scenario Outline: Handle Out of Stock Situations
  Given out of stock items are <input:state.oos_items>
  And estimated restock date is <input:state.restock_date>
  And customer notification preference is <input:state.notification_preference>
  When the inventory system processes the shortage
  Then it should execute tool <mcp_tool:name>
  And set stock status to <output:state.stock_status>
  And create restock notification as <output:state.restock_notification>
  And record shortage timestamp as <output:state.shortage_timestamp>
  And set alternative suggestions to <output:state.alternative_suggestions>

  Examples: Out of stock completion table
    | input:state.oos_items | input:state.restock_date | input:state.notification_preference | mcp_tool:name | mcp_tool:output_sample | output:state.stock_status | output:state.restock_notification | output:state.shortage_timestamp | output:state.alternative_suggestions | probability | transition |
    | state.oos_items | state.restock_date | "email_notification" | create_file | {"out_of_stock": true, "restock_alert_set": true, "alternatives_suggested": true, "customer_notified": true} | "temporarily_out_of_stock" | "restock_alert_created" | new Date().toISOString() | "similar_products_suggested" | 1.0 | |

@flow:end_node
@scenario_id:payment-failed
@context:payment_failure,transaction_declined
Scenario Outline: Handle Payment Processing Failures
  Given payment failure reason is <input:state.payment_failure_reason>
  And transaction details are <input:state.transaction_details>
  And retry eligibility is <input:state.retry_eligible>
  When the payment failure system processes the decline
  Then it should execute tool <mcp_tool:name>
  And set payment failure status to <output:state.payment_failure_status>
  And create retry guidance as <output:state.retry_guidance>
  And record failure timestamp as <output:state.failure_timestamp>
  And set customer support contact to <output:state.support_contact>

  Examples: Payment failure completion table
    | input:state.payment_failure_reason | input:state.transaction_details | input:state.retry_eligible | mcp_tool:name | mcp_tool:output_sample | output:state.payment_failure_status | output:state.retry_guidance | output:state.failure_timestamp | output:state.support_contact | probability | transition |
    | state.payment_failure_reason | state.transaction_details | true | create_file | {"payment_failed": true, "retry_allowed": true, "guidance_provided": true, "support_available": true} | "payment_declined_retry_allowed" | "retry_with_different_payment_method" | new Date().toISOString() | "payment_support_team" | 1.0 | |

@flow:end_node
@scenario_id:customs-processing
@context:international_shipping,customs_clearance
Scenario Outline: Handle International Customs Processing
  Given international shipment details are <input:state.international_shipment>
  And customs documentation is <input:state.customs_docs>
  And destination country requirements are <input:state.country_requirements>
  When the customs processing system handles the shipment
  Then it should execute tool <mcp_tool:name>
  And set customs status to <output:state.customs_status>
  And update documentation status to <output:state.documentation_status>
  And record customs timestamp as <output:state.customs_timestamp>
  And set clearance tracking to <output:state.clearance_tracking>

  Examples: Customs processing completion table
    | input:state.international_shipment | input:state.customs_docs | input:state.country_requirements | mcp_tool:name | mcp_tool:output_sample | output:state.customs_status | output:state.documentation_status | output:state.customs_timestamp | output:state.clearance_tracking | probability | transition |
    | state.international_shipment | "complete_documentation" | state.country_requirements | semantic_search | {"customs_submitted": true, "documentation_complete": true, "clearance_initiated": true, "tracking_enabled": true} | "customs_processing_initiated" | "documentation_complete_and_submitted" | new Date().toISOString() | "customs_tracking_" + state.shipment_id | 1.0 | |

@flow:end_node
@scenario_id:payment-pending
@context:payment_delay,bank_transfer_processing
Scenario Outline: Handle Pending Payment Processing
  Given pending payment type is <input:state.pending_payment_type>
  And expected clearance time is <input:state.clearance_time>
  And order hold status is <input:state.hold_status>
  When the pending payment system manages the delay
  Then it should execute tool <mcp_tool:name>
  And set pending status to <output:state.pending_status>
  And create hold notification as <output:state.hold_notification>
  And record pending timestamp as <output:state.pending_timestamp>
  And set monitoring schedule to <output:state.monitoring_schedule>

  Examples: Payment pending completion table
    | input:state.pending_payment_type | input:state.clearance_time | input:state.hold_status | mcp_tool:name | mcp_tool:output_sample | output:state.pending_status | output:state.hold_notification | output:state.pending_timestamp | output:state.monitoring_schedule | probability | transition |
    | "bank_transfer" | state.clearance_time | "order_on_hold" | file_search | {"payment_pending": true, "order_held": true, "monitoring_active": true, "customer_notified": true} | "payment_clearance_pending" | "order_hold_notification_sent" | new Date().toISOString() | "daily_payment_status_check" | 1.0 | |

@flow:end_node
@scenario_id:fraud-escalation
@context:fraud_escalation,management_review
Scenario Outline: Handle Fraud Case Escalation
  Given escalation reason is <input:state.escalation_reason>
  And escalation level is <input:state.escalation_level>
  And management review requirements are <input:state.management_review_requirements>
  When the fraud escalation system processes the case
  Then it should execute tool <mcp_tool:name>
  And set escalation status to <output:state.escalation_status>
  And create management alert as <output:state.management_alert>
  And record escalation timestamp as <output:state.escalation_timestamp>
  And set review priority to <output:state.review_priority>

  Examples: Fraud escalation completion table
    | input:state.escalation_reason | input:state.escalation_level | input:state.management_review_requirements | mcp_tool:name | mcp_tool:output_sample | output:state.escalation_status | output:state.management_alert | output:state.escalation_timestamp | output:state.review_priority | probability | transition |
    | "high_value_fraud_suspected" | "senior_management" | "immediate_review" | run_in_terminal | {"escalated_to_management": true, "alert_created": "MGMT-FRAUD-001", "immediate_attention": true, "legal_review": "initiated"} | "escalated_to_senior_management" | "MGMT-FRAUD-" + generate_alert_id() | new Date().toISOString() | "immediate_priority" | 1.0 | |

@flow:end_node
@scenario_id:order-cancelled
@context:order_cancellation,customer_request
Scenario Outline: Handle Order Cancellation
  Given cancellation reason is <input:state.cancellation_reason>
  And cancellation timestamp is <input:state.cancellation_timestamp>
  And refund requirement is <input:state.refund_required>
  And inventory release needed is <input:state.inventory_release>
  When the order cancellation system processes the request
  Then it should execute tool <mcp_tool:name>
  And set cancellation status to <output:state.cancellation_status>
  And update refund processing to <output:state.refund_processing>
  And record cancellation completion as <output:state.cancellation_completion>
  And set inventory status to <output:state.inventory_status>

  Examples: Order cancellation completion table
    | input:state.cancellation_reason | input:state.cancellation_timestamp | input:state.refund_required | input:state.inventory_release | mcp_tool:name | mcp_tool:output_sample | output:state.cancellation_status | output:state.refund_processing | output:state.cancellation_completion | output:state.inventory_status | probability | transition |
    | state.cancellation_reason | state.cancellation_timestamp | true | true | create_file | {"order_cancelled": true, "refund_initiated": true, "inventory_released": true, "customer_notified": true} | "order_successfully_cancelled" | "refund_processing_initiated" | "cancellation_completed_" + state.timestamp | "inventory_returned_to_available" | 1.0 | |

@flow:end_node
@scenario_id:freight-coordination
@context:freight_shipping,special_handling
Scenario Outline: Handle Freight and Special Shipping Coordination
  Given freight requirements are <input:state.freight_requirements>
  And special handling needs are <input:state.special_handling>
  And delivery appointment scheduling is <input:state.appointment_scheduling>
  When the freight coordination system manages the shipment
  Then it should execute tool <mcp_tool:name>
  And set freight status to <output:state.freight_status>
  And update delivery scheduling to <output:state.delivery_scheduling>
  And record coordination timestamp as <output:state.coordination_timestamp>
  And set special instructions to <output:state.special_instructions>

  Examples: Freight coordination completion table
    | input:state.freight_requirements | input:state.special_handling | input:state.appointment_scheduling | mcp_tool:name | mcp_tool:output_sample | output:state.freight_status | output:state.delivery_scheduling | output:state.coordination_timestamp | output:state.special_instructions | probability | transition |
    | state.freight_requirements | state.special_handling | "appointment_required" | semantic_search | {"freight_coordinated": true, "appointment_scheduled": true, "special_handling_arranged": true, "delivery_window": "confirmed"} | "freight_shipping_coordinated" | "delivery_appointment_scheduled" | new Date().toISOString() | "special_handling_instructions_provided" | 1.0 | |

@flow:end_node
@scenario_id:special-handling
@context:special_delivery,remote_shipping
Scenario Outline: Handle Special Delivery Requirements
  Given special delivery requirements are <input:state.special_delivery_requirements>
  And remote location challenges are <input:state.remote_challenges>
  And additional handling fees are <input:state.additional_fees>
  When the special handling system processes the requirements
  Then it should execute tool <mcp_tool:name>
  And set special handling status to <output:state.special_handling_status>
  And update delivery timeline to <output:state.delivery_timeline>
  And record handling timestamp as <output:state.handling_timestamp>
  And set fee adjustment to <output:state.fee_adjustment>

  Examples: Special handling completion table
    | input:state.special_delivery_requirements | input:state.remote_challenges | input:state.additional_fees | mcp_tool:name | mcp_tool:output_sample | output:state.special_handling_status | output:state.delivery_timeline | output:state.handling_timestamp | output:state.fee_adjustment | probability | transition |
    | state.special_delivery_requirements | state.remote_challenges | state.additional_fees | create_file | {"special_handling_arranged": true, "remote_delivery_coordinated": true, "fees_calculated": true, "extended_timeline": "applied"} | "special_delivery_arranged" | "extended_delivery_timeline_applied" | new Date().toISOString() | "additional_fees_" + state.additional_fees | 1.0 | |

@flow:end_node
@scenario_id:inventory-hold
@context:inventory_reservation,wait_fulfillment
Scenario Outline: Handle Inventory Hold for Complete Order
  Given inventory hold reason is <input:state.hold_reason>
  And expected availability date is <input:state.expected_availability>
  And customer wait preference is <input:state.wait_preference>
  When the inventory hold system manages the reservation
  Then it should execute tool <mcp_tool:name>
  And set hold status to <output:state.hold_status>
  And update availability monitoring to <output:state.availability_monitoring>
  And record hold timestamp as <output:state.hold_timestamp>
  And set customer communication to <output:state.customer_communication>

  Examples: Inventory hold completion table
    | input:state.hold_reason | input:state.expected_availability | input:state.wait_preference | mcp_tool:name | mcp_tool:output_sample | output:state.hold_status | output:state.availability_monitoring | output:state.hold_timestamp | output:state.customer_communication | probability | transition |
    | "waiting_for_complete_order" | state.expected_availability | "customer_prefers_complete_shipment" | file_search | {"inventory_held": true, "availability_monitored": true, "customer_updated": true, "shipment_delayed": true} | "order_held_for_complete_fulfillment" | "daily_availability_check_enabled" | new Date().toISOString() | "delay_notification_and_updates_scheduled" | 1.0 | |

@flow:end_node
@scenario_id:customer-choice-required
@context:customer_decision,long_backorder
Scenario Outline: Handle Customer Choice for Long Backorders
  Given long backorder duration is <input:state.backorder_duration>
  And alternative options are <input:state.alternative_options>
  And customer decision requirement is <input:state.decision_requirement>
  When the customer choice system presents options
  Then it should execute tool <mcp_tool:name>
  And set choice presentation status to <output:state.choice_status>
  And update customer notification to <output:state.customer_notification>
  And record choice timestamp as <output:state.choice_timestamp>
  And set decision deadline to <output:state.decision_deadline>

  Examples: Customer choice completion table
    | input:state.backorder_duration | input:state.alternative_options | input:state.decision_requirement | mcp_tool:name | mcp_tool:output_sample | output:state.choice_status | output:state.customer_notification | output:state.choice_timestamp | output:state.decision_deadline | probability | transition |
    | state.backorder_duration > 30 | state.alternative_options | "customer_decision_required" | create_file | {"choice_presented": true, "alternatives_offered": true, "decision_deadline_set": true, "customer_contacted": true} | "customer_choice_options_presented" | "long_backorder_choice_notification_sent" | new Date().toISOString() | calculate_decision_deadline(7) | 1.0 | |

@flow:end_node
@scenario_id:management-approval
@context:management_decision,bulk_order_approval
Scenario Outline: Handle Management Approval for Large Orders
  Given management approval requirement is <input:state.approval_requirement>
  And order complexity level is <input:state.complexity_level>
  And business impact assessment is <input:state.business_impact>
  When the management approval system processes the request
  Then it should execute tool <mcp_tool:name>
  And set approval request status to <output:state.approval_status>
  And update management notification to <output:state.management_notification>
  And record approval timestamp as <output:state.approval_timestamp>
  And set decision timeline to <output:state.decision_timeline>

  Examples: Management approval completion table
    | input:state.approval_requirement | input:state.complexity_level | input:state.business_impact | mcp_tool:name | mcp_tool:output_sample | output:state.approval_status | output:state.management_notification | output:state.approval_timestamp | output:state.decision_timeline | probability | transition |
    | "bulk_order_management_approval" | "high_complexity" | "significant_business_impact" | run_in_terminal | {"approval_requested": true, "management_notified": true, "review_scheduled": true, "decision_pending": true} | "management_approval_requested" | "bulk_order_approval_notification_sent" | new Date().toISOString() | "48_hour_decision_timeline" | 1.0 | |

@flow:end_node
@scenario_id:inventory-insufficient
@context:inventory_shortage,insufficient_stock
Scenario Outline: Handle Insufficient Inventory for Bulk Orders
  Given inventory shortage details are <input:state.shortage_details>
  And suggested alternatives are <input:state.suggested_alternatives>
  And special order options are <input:state.special_order_options>
  When the inventory insufficient system handles the shortage
  Then it should execute tool <mcp_tool:name>
  And set insufficiency status to <output:state.insufficiency_status>
  And update alternative suggestions to <output:state.alternative_suggestions>
  And record shortage timestamp as <output:state.shortage_timestamp>
  And set special order availability to <output:state.special_order_availability>

  Examples: Inventory insufficient completion table
    | input:state.shortage_details | input:state.suggested_alternatives | input:state.special_order_options | mcp_tool:name | mcp_tool:output_sample | output:state.insufficiency_status | output:state.alternative_suggestions | output:state.shortage_timestamp | output:state.special_order_availability | probability | transition |
    | state.shortage_details | state.suggested_alternatives | "special_order_available" | semantic_search | {"inventory_insufficient": true, "alternatives_suggested": true, "special_order_offered": true, "customer_notified": true} | "bulk_order_inventory_insufficient" | "reduced_quantity_and_alternatives_suggested" | new Date().toISOString() | "special_order_manufacturing_available" | 1.0 | |

@flow:end_node
@scenario_id:payment-retry
@context:payment_system_retry,gateway_recovery
Scenario Outline: Handle Payment System Retry
  Given payment retry reason is <input:state.retry_reason>
  And gateway recovery status is <input:state.gateway_recovery>
  And retry attempt count is <input:state.retry_attempts>
  When the payment retry system processes the recovery
  Then it should execute tool <mcp_tool:name>
  And set retry status to <output:state.retry_status>
  And update gateway monitoring to <output:state.gateway_monitoring>
  And record retry timestamp as <output:state.retry_timestamp>
  And set next retry schedule to <output:state.next_retry_schedule>

  Examples: Payment retry completion table
    | input:state.retry_reason | input:state.gateway_recovery | input:state.retry_attempts | mcp_tool:name | mcp_tool:output_sample | output:state.retry_status | output:state.gateway_monitoring | output:state.retry_timestamp | output:state.next_retry_schedule | probability | transition |
    | "gateway_temporarily_unavailable" | "recovery_in_progress" | state.retry_attempts < 3 | run_in_terminal | {"retry_scheduled": true, "gateway_monitored": true, "customer_notified": true, "order_held": true} | "payment_retry_scheduled" | "gateway_recovery_monitoring_enabled" | new Date().toISOString() | "retry_in_30_minutes" | 1.0 | |

@flow:end_node
@scenario_id:address-validation-required
@context:address_correction,shipping_validation
Scenario Outline: Handle Address Validation Requirements
  Given invalid address details are <input:state.invalid_address_details>
  And address correction suggestions are <input:state.correction_suggestions>
  And customer contact requirement is <input:state.contact_requirement>
  When the address validation system processes the error
  Then it should execute tool <mcp_tool:name>
  And set validation status to <output:state.validation_status>
  And update correction suggestions to <output:state.correction_suggestions>
  And record validation timestamp as <output:state.validation_timestamp>
  And set customer notification to <output:state.customer_notification>

  Examples: Address validation completion table
    | input:state.invalid_address_details | input:state.correction_suggestions | input:state.contact_requirement | mcp_tool:name | mcp_tool:output_sample | output:state.validation_status | output:state.correction_suggestions | output:state.validation_timestamp | output:state.customer_notification | probability | transition |
    | state.invalid_address_details | state.correction_suggestions | "customer_contact_required" | create_file | {"address_validation_required": true, "suggestions_provided": true, "customer_contacted": true, "order_held": true} | "address_validation_pending" | "address_correction_suggestions_provided" | new Date().toISOString() | "address_correction_notification_sent" | 1.0 | |

@flow:end_node
@scenario_id:customer-blocked
@context:account_restrictions,customer_blocking
Scenario Outline: Handle Blocked Customer Account
  Given customer blocking reason is <input:state.blocking_reason>
  And account restriction details are <input:state.restriction_details>
  And support escalation requirement is <input:state.escalation_requirement>
  When the customer blocking system processes the restriction
  Then it should execute tool <mcp_tool:name>
  And set blocking status to <output:state.blocking_status>
  And create support escalation as <output:state.support_escalation>
  And record blocking timestamp as <output:state.blocking_timestamp>
  And set resolution guidance to <output:state.resolution_guidance>

  Examples: Customer blocking completion table
    | input:state.blocking_reason | input:state.restriction_details | input:state.escalation_requirement | mcp_tool:name | mcp_tool:output_sample | output:state.blocking_status | output:state.support_escalation | output:state.blocking_timestamp | output:state.resolution_guidance | probability | transition |
    | state.blocking_reason | state.restriction_details | "immediate_escalation" | run_in_terminal | {"customer_blocked": true, "escalation_created": "CUST-BLOCK-001", "support_notified": true, "resolution_process": "initiated"} | "customer_account_blocked" | "CUST-BLOCK-" + generate_escalation_id() | new Date().toISOString() | "contact_customer_support_for_resolution" | 1.0 | |

@flow:end_node
@scenario_id:inventory-system-error
@context:system_failure,inventory_unavailable
Scenario Outline: Handle Inventory System Errors
  Given inventory system error type is <input:state.system_error_type>
  And system recovery estimate is <input:state.recovery_estimate>
  And manual check feasibility is <input:state.manual_check_feasible>
  When the inventory system error handler processes the failure
  Then it should execute tool <mcp_tool:name>
  And set error status to <output:state.error_status>
  And update recovery monitoring to <output:state.recovery_monitoring>
  And record error timestamp as <output:state.error_timestamp>
  And set customer communication to <output:state.customer_communication>

  Examples: Inventory system error completion table
    | input:state.system_error_type | input:state.recovery_estimate | input:state.manual_check_feasible | mcp_tool:name | mcp_tool:output_sample | output:state.error_status | output:state.recovery_monitoring | output:state.error_timestamp | output:state.customer_communication | probability | transition |
    | "database_connectivity_failure" | state.recovery_estimate | "manual_check_possible" | run_in_terminal | {"system_error": true, "recovery_monitoring": true, "manual_process_initiated": true, "customer_notified": true} | "inventory_system_temporarily_unavailable" | "system_recovery_monitoring_enabled" | new Date().toISOString() | "system_maintenance_notification_sent" | 1.0 | |

@flow:end_node
@scenario_id:product-discontinued
@context:product_availability,discontinued_items
Scenario Outline: Handle Discontinued Product Orders
  Given discontinued product details are <input:state.discontinued_products>
  And alternative product suggestions are <input:state.alternative_suggestions>
  And customer notification requirement is <input:state.notification_requirement>
  When the discontinued product system processes the unavailability
  Then it should execute tool <mcp_tool:name>
  And set discontinuation status to <output:state.discontinuation_status>
  And update alternative offerings to <output:state.alternative_offerings>
  And record discontinuation timestamp as <output:state.discontinuation_timestamp>
  And set customer guidance to <output:state.customer_guidance>

  Examples: Product discontinued completion table
    | input:state.discontinued_products | input:state.alternative_suggestions | input:state.notification_requirement | mcp_tool:name | mcp_tool:output_sample | output:state.discontinuation_status | output:state.alternative_offerings | output:state.discontinuation_timestamp | output:state.customer_guidance | probability | transition |
    | state.discontinued_products | state.alternative_suggestions | "customer_notification_required" | semantic_search | {"products_discontinued": true, "alternatives_provided": true, "customer_notified": true, "order_modification": "required"} | "products_no_longer_available" | "alternative_products_suggested" | new Date().toISOString() | "order_modification_guidance_provided" | 1.0 | |