class Blackboard extends HashMap<String, Double>
{

	String processExpression(String expr) {
  	for (HashMap.Entry<String, Double> element : entrySet()) {
	    expr = expr.replaceAll("\\["+element.getKey()+"\\]", element.getValue().toString());
	  }
		return expr;
	}

}
