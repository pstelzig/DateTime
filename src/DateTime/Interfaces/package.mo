within DateTime;

package Interfaces "Library of connectors, partial classes and blocks for the Datetime package. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-present. ALL RIGHTS RESERVED."
  extends Modelica.Icons.InterfacesPackage;

  partial block SO "Single Out"
    extends Modelica.Blocks.Icons.Block;
    Modelica.Blocks.Interfaces.RealOutput y annotation(
      Placement(transformation(extent = {{100, -10}, {120, 10}})));
  end SO;

  partial block MO "Multiple Output"
    extends Modelica.Blocks.Icons.Block;
    parameter Integer nout(min = 1) = 1 "Number of outputs";
    Modelica.Blocks.Interfaces.RealOutput y[nout] "Connector of Real output signals" annotation(
      Placement(transformation(extent = {{100, -10}, {120, 10}})));
  end MO;

  partial block BooleanSO "Boolean Single Out"
    extends Modelica.Blocks.Icons.BooleanBlock;
  public
    Modelica.Blocks.Interfaces.BooleanOutput y "Connector of Boolean output signal" annotation(
      Placement(transformation(extent = {{100, -10}, {120, 10}})));
  end BooleanSO;

  partial block IntegerSO "Integer Single Out"
    extends Modelica.Blocks.Interfaces.IntegerSO;
  end IntegerSO;
  
  partial block IntegerMO "Integer Multiple Out"
    extends Modelica.Blocks.Interfaces.IntegerMO;
  end IntegerMO;  
end Interfaces;