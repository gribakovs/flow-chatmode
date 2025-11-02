# Health Insurance Claim Processing Flow - Test Cases

This document contains comprehensive test cases for evaluating the health insurance claim processing decision flow. Each test case demonstrates different paths through the decision graph and covers various scenarios including emergency claims, routine processing, fraud detection, and administrative workflows.

## How to Use These Test Cases

1. **Copy any prompt** from the test cases below
2. **Use with Flow chatmode** by asking: "Evaluate the health-insurance-claim-flow for input: [paste prompt here]"
3. **Expected Output**: The AI will provide detailed traversal reports including:
   - State object creation and initialization
   - Step-by-step node evaluation with before/after states
   - Decision logic explanations with probability reasoning
   - MCP tool execution results (mocked outputs)
   - ASCII visualization of the traversal path
   - Final execution summary with alternative paths

---

## Test Case 1: Emergency High-Value Claim (Priority Path)

**Scenario**: Emergency treatment with high claim amount requiring priority review
**Expected Path**: claim-intake → priority-review → payment-approval
**Key Features**: Tests emergency override, high-value processing, immediate approval

```
Evaluate the health-insurance-claim-flow for input: 
claim_type='emergency', 
claim_amount=15000, 
policy_status='active', 
member_tier='premium', 
member_id='MBR-12345', 
service_date='2025-10-30', 
provider_network='in_network', 
urgency_level='critical', 
medical_necessity='medically_necessary', 
prior_auth_status='not_required'
```

**Expected Outcomes**:
- Triggers high-priority review due to emergency + high amount
- Emergency override bypasses standard review processes
- Immediate approval with full coverage calculation
- Fast-track payment processing

---

## Test Case 2: Routine Preventive Care (Auto-Approval Path)

**Scenario**: Preventive care claim with 100% coverage
**Expected Path**: claim-intake → auto-approval
**Key Features**: Tests fast-track preventive care, 100% coverage, minimal processing time

```
Evaluate the health-insurance-claim-flow for input:
claim_type='preventive',
claim_amount=250,
policy_status='active',
member_tier='standard',
member_id='MBR-67890',
service_date='2025-10-25',
provider_network='in_network',
auto_approval_reason='preventive_care'
```

**Expected Outcomes**:
- Automatic approval without manual review
- 100% coverage with no member responsibility
- Processing time under 1 minute
- No deductible application

---

## Test Case 3: Medium-Amount Routine Claim (Manual Review Path)

**Scenario**: Routine claim exceeding auto-approval threshold requiring manual review
**Expected Path**: claim-intake → manual-review → payment-calculation → payment-approval
**Key Features**: Tests probabilistic reviewer assignment, amount threshold triggers, manual review workflow

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=7500,
policy_status='active',
member_tier='standard',
member_id='MBR-11111',
service_date='2025-10-28',
provider_network='in_network',
review_reason='high_amount',
complexity_level='complex',
reviewer_available='senior_reviewer',
queue_size=8
```

**Expected Outcomes**:
- Amount threshold triggers manual review requirement
- Probabilistic assignment to senior reviewer (70% probability)
- Standard coverage calculation with deductible application
- 4-8 hour review timeline

---

## Test Case 4: Fraud Investigation Trigger (High-Risk Path)

**Scenario**: Very high-value claim triggering fraud investigation with suspicious patterns
**Expected Path**: claim-intake → fraud-investigation → fraud-hold
**Key Features**: Tests fraud detection system, high-risk scoring, claim suspension

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=125000,
policy_status='active',
member_tier='premium',
fraud_threshold=50000,
pattern_analysis='multiple_red_flags',
provider_history='suspicious_activity',
member_history='excessive_claims',
investigation_type='full_investigation'
```

**Expected Outcomes**:
- Automatic fraud investigation trigger at $125K claim
- High fraud risk score (0.8) due to multiple red flags
- Full investigation hold placed on claim
- 30-day investigation timeline with member notification

---

## Test Case 5: Policy Inactive (Immediate Denial Path)

**Scenario**: Claim submitted for inactive policy
**Expected Path**: claim-intake → claim-denied
**Key Features**: Tests immediate denial for inactive policies, no appeal rights

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=500,
policy_status='inactive',
member_tier='standard',
member_id='MBR-99999',
denial_reason='policy_inactive',
appeal_eligible=false,
denial_category='administrative'
```

**Expected Outcomes**:
- Immediate administrative denial
- No payment processing or eligibility check
- No appeal rights available
- Immediate member notification

---

## Test Case 6: Out-of-Network Provider (Reduced Coverage Path)

**Scenario**: Routine claim with out-of-network provider
**Expected Path**: claim-intake → eligibility-check → payment-calculation → payment-approval
**Key Features**: Tests reduced coverage (60%), out-of-network penalties, deductible application

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=3000,
policy_status='active',
member_tier='standard',
member_id='MBR-55555',
service_date='2025-10-29',
provider_network='out_of_network',
deductible_status='deductible_not_met'
```

**Expected Outcomes**:
- Reduced coverage to 60% due to out-of-network status
- Additional out-of-network penalties applied
- Higher member responsibility
- Standard payment processing with reduced amount

---

## Test Case 7: Experimental Treatment (Medical Board Review Path)

**Scenario**: High-cost experimental treatment requiring expert medical review
**Expected Path**: claim-intake → priority-review → medical-board-review
**Key Features**: Tests experimental treatment workflow, medical board evaluation, expert review process

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=45000,
policy_status='active',
member_tier='premium',
priority_reason='experimental_treatment',
urgency_level='medium',
medical_necessity='under_review',
prior_auth_status='pending',
medical_complexity='high_complexity',
review_type='experimental_treatment',
evidence_quality='strong_evidence'
```

**Expected Outcomes**:
- Priority review identifies experimental treatment
- Referral to medical board for expert evaluation
- 14-day expert review timeline
- Conditional approval with monitoring requirements

---

## Test Case 8: Prior Authorization Required (Auth Workflow Path)

**Scenario**: High-cost procedure requiring prior authorization
**Expected Path**: claim-intake → priority-review → prior-auth-request → manual-review
**Key Features**: Tests prior authorization workflow, credential verification, authorization pending state

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=8000,
policy_status='active',
member_tier='premium',
priority_reason='routine_high_cost',
urgency_level='low',
medical_necessity='medically_necessary',
prior_auth_status='expired',
service_type='elective_surgery',
request_urgency='standard',
provider_credentials='network_provider'
```

**Expected Outcomes**:
- Priority review identifies expired authorization
- Prior authorization request initiated
- 5-day medical review timeline
- Hold on claim processing until authorization approved

---

## Test Case 9: Service Date Invalid (Administrative Denial)

**Scenario**: Claim with service date outside policy period
**Expected Path**: claim-intake → eligibility-check → claim-denied
**Key Features**: Tests service date validation, administrative denial with appeal rights

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=1200,
policy_status='active',
member_tier='standard',
member_id='MBR-33333',
service_date='2024-12-15',
provider_network='in_network',
denial_reason='service_date_invalid',
appeal_eligible=true,
denial_category='administrative'
```

**Expected Outcomes**:
- Eligibility check fails due to invalid service date
- Administrative denial with appeal rights
- 30-day appeal deadline provided
- Correction notice sent to member

---

## Test Case 10: Fraud Investigation - Low Risk (Expedited Clearance)

**Scenario**: High-value claim with fraud check but low risk profile
**Expected Path**: claim-intake → fraud-investigation → eligibility-check → payment-calculation → payment-approval
**Key Features**: Tests fraud detection with low-risk clearance, expedited processing after security check

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=30000,
policy_status='active',
member_tier='premium',
fraud_threshold=25000,
pattern_analysis='normal_pattern',
provider_history='verified_provider',
member_history='first_time_claim',
member_id='MBR-77777',
service_date='2025-10-30',
provider_network='in_network'
```

**Expected Outcomes**:
- Automatic fraud investigation due to amount threshold
- Low fraud risk score (0.1) allows expedited clearance
- Standard eligibility and payment processing
- No additional holds or delays

---

## Test Case 11: Complex Manual Review with Document Specialist

**Scenario**: Documentation-heavy claim requiring specialist review
**Expected Path**: claim-intake → manual-review → payment-calculation → payment-approval
**Key Features**: Tests documentation specialist assignment, AI-assisted review

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=4500,
policy_status='active',
member_tier='standard',
member_id='MBR-44444',
service_date='2025-10-29',
provider_network='in_network',
review_reason='documentation',
complexity_level='medium',
reviewer_available='document_specialist',
queue_size=3
```

**Expected Outcomes**:
- Manual review triggered by documentation complexity
- Assignment to documentation specialist (60% probability)
- AI-assisted review reducing processing time
- 3-hour review timeline with medium priority

---

## Test Case 12: Network Provider Verification Failure

**Scenario**: Prior authorization request with invalid provider credentials
**Expected Path**: claim-intake → priority-review → prior-auth-request → claim-denied
**Key Features**: Tests provider credential verification, immediate denial for invalid providers

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=5500,
policy_status='active',
member_tier='premium',
priority_reason='routine_high_cost',
urgency_level='low',
medical_necessity='medically_necessary',
prior_auth_status='expired',
service_type='diagnostic_imaging',
request_urgency='routine',
provider_credentials='invalid_provider'
```

**Expected Outcomes**:
- Prior authorization process detects invalid provider
- Immediate denial due to credential verification failure
- No payment processing or further review
- Provider notification of credential issues

---

## Advanced Test Scenarios

### Test Case 13: Multiple Reviewer Types Available (Chance Node Testing)

**Scenario**: Testing probabilistic reviewer assignment with multiple options
**Expected Path**: claim-intake → manual-review → [probabilistic routing]
**Key Features**: Tests chance node probability selection with multiple matching rows

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=6000,
policy_status='active',
member_tier='standard',
member_id='MBR-88888',
service_date='2025-10-30',
provider_network='in_network',
review_reason='provider_network',
complexity_level='simple',
reviewer_available='any_available',
queue_size=12
```

**Expected Outcomes**:
- Manual review required for provider network verification
- Probabilistic assignment to network reviewer (80% probability)
- Automated assistance available for simple cases
- 2-hour standard review timeline

---

### Test Case 14: Deductible Met Scenario

**Scenario**: Claim processing when member has already met annual deductible
**Expected Path**: claim-intake → eligibility-check → payment-calculation → payment-approval
**Key Features**: Tests higher coverage percentage when deductible is satisfied

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=2000,
policy_status='active',
member_tier='standard',
member_id='MBR-22222',
service_date='2025-10-30',
provider_network='in_network',
deductible_status='deductible_met'
```

**Expected Outcomes**:
- Higher coverage percentage (90%) due to met deductible
- Reduced member responsibility
- No deductible application to current claim
- Standard payment processing timeline

---

## Performance Testing Scenarios

### Test Case 15: High-Volume Queue Testing

**Scenario**: Manual review assignment during peak processing times
**Expected Path**: claim-intake → manual-review → [queue-based routing]
**Key Features**: Tests reviewer assignment logic with high queue volumes

```
Evaluate the health-insurance-claim-flow for input:
claim_type='routine',
claim_amount=6500,
policy_status='active',
member_tier='standard',
member_id='MBR-66666',
service_date='2025-10-30',
provider_network='in_network',
review_reason='high_amount',
complexity_level='complex',
reviewer_available='standard_reviewer',
queue_size=25
```

**Expected Outcomes**:
- Manual review triggered by amount and complexity
- Assignment to standard reviewer due to high queue volume
- Extended review timeline (8 hours) due to capacity constraints
- Backup support activated for complex cases

---

## Edge Case Testing

### Test Case 16: Boundary Amount Testing ($50,000 Fraud Threshold)

**Scenario**: Claim exactly at fraud investigation threshold
**Expected Path**: claim-intake → fraud-investigation → [risk-based routing]
**Key Features**: Tests exact threshold boundary conditions

```
Evaluate the health-insurance-claim-flow for input:
claim_type='specialist',
claim_amount=50000,
policy_status='active',
member_tier='premium',
fraud_threshold=50000,
pattern_analysis='normal_pattern',
provider_history='clean_history',
member_history='normal_usage'
```

**Expected Outcomes**:
- Fraud investigation triggered at exact threshold
- Standard investigation due to normal risk profile
- Risk score evaluation and clearance decision
- Potential routing to manual review or eligibility check

---

## Summary of Test Coverage

| Test Case | Primary Path | Node Types | Key Features |
|-----------|--------------|------------|--------------|
| 1 | Emergency Priority | Decision → End | Emergency override, high-value |
| 2 | Preventive Auto | Decision → End | 100% coverage, fast-track |
| 3 | Manual Review | Decision → Chance → Decision → End | Probabilistic assignment |
| 4 | Fraud Hold | Decision → Decision → End | High-risk detection |
| 5 | Policy Denial | Decision → End | Administrative denial |
| 6 | Out-of-Network | Decision → Decision → Decision → End | Reduced coverage |
| 7 | Medical Board | Decision → Decision → End | Expert review |
| 8 | Prior Auth | Decision → Decision → Transition → Decision | Authorization workflow |
| 9 | Date Invalid | Decision → Decision → End | Service date validation |
| 10 | Low-Risk Fraud | Decision → Decision → Decision → Decision → End | Expedited clearance |
| 11-16 | Various | Multiple combinations | Edge cases, performance, boundaries |

**Total Coverage**:
- **Decision Nodes**: 8 scenarios fully tested
- **End Nodes**: 6 scenarios covered
- **Chance Nodes**: 1 scenario with probabilistic testing
- **Transition Logic**: 1 scenario with auth workflow
- **Edge Cases**: Boundary conditions, high-volume, error scenarios

All major decision paths, node types, and business logic combinations are comprehensively tested with realistic healthcare claim scenarios.